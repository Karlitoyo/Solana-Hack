use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program::invoke,
    program_error::ProgramError,
    pubkey::Pubkey,
    system_instruction,
};

// Define constants for your contract
const MAX_LENDERS: usize = 100;

// Implement your contract methods here
pub fn add_funds(
    accounts: &[AccountInfo],
) -> ProgramResult {
    // Extract account info
    let account_info_iter = &mut accounts.iter();
    let lender_account = next_account_info(account_info_iter)?;

    // Check if the lender already exists in the list
    let mut lender_exists = false;
    let mut num_of_lenders = 0;
    let mut lut_lenders: [Pubkey; MAX_LENDERS] = [Pubkey::default(); MAX_LENDERS];
    for account in account_info_iter {
        if num_of_lenders >= MAX_LENDERS {
            break;
        }
        lut_lenders[num_of_lenders] = *account.key;
        if account.key == lender_account.key {
            lender_exists = true;
            break;
        }
        num_of_lenders += 1;
    }

    // If lender doesn't exist, add them
    if !lender_exists && num_of_lenders < MAX_LENDERS {
        let lender_index = num_of_lenders;
        lut_lenders[lender_index] = *lender_account.key;
        msg!("Lender added successfully");
    } else {
        msg!("Lender already exists or max lenders reached");
    }

    Ok(())
}

pub fn withdraw(
    accounts: &[AccountInfo],
    withdraw_amount: u64,
) -> ProgramResult {
    // Extract account info
    let account_info_iter = &mut accounts.iter();
    let lender_account = next_account_info(account_info_iter)?;

    // Check if the lender exists in the list
    let mut lender_index = None;
    for (i, &lender) in lut_lenders.iter().enumerate() {
        if lender == *lender_account.key {
            lender_index = Some(i);
            break;
        }
    }

    match lender_index {
        Some(index) => {
            // Check if there are sufficient funds in the contract
            let contract_balance = lender_account.lamports();
            if withdraw_amount <= contract_balance {
                // Transfer funds to the sender
                let transfer_to = lender_account.key;
                let system_program = next_account_info(account_info_iter)?;
                let transfer_instruction = system_instruction::transfer(
                    lender_account.key,
                    transfer_to,
                    withdraw_amount,
                );
                invoke(
                    &transfer_instruction,
                    &[lender_account.clone(), system_program.clone()],
                )?;
                msg!("Withdraw successful");
            } else {
                msg!("Insufficient funds in the contract");
                return Err(ProgramError::InsufficientFunds);
            }
        }
        None => {
            msg!("Lender not found");
            return Err(ProgramError::InvalidAccountData);
        }
    }

    Ok(())
}

// Entry point function for Solana program
entrypoint! {
    pub fn process_instruction(
        _program_id: &Pubkey,
        accounts: &[AccountInfo],
        instruction_data: &[u8],
    ) -> ProgramResult {
        // Parse instruction data and call appropriate contract methods
        match instruction_data[0] {
            0 => {
                add_funds(accounts)?;
            }
            1 => {
                // Parse the instruction data for withdraw amount
                let withdraw_amount = instruction_data[1..9].to_le_bytes();
                let withdraw_amount = u64::from_le_bytes(withdraw_amount);
                withdraw(accounts, withdraw_amount)?;
            }
            _ => {
                msg!("Invalid instruction");
                return Err(ProgramError::InvalidInstructionData);
            }
        }

        Ok(())
    }
}
