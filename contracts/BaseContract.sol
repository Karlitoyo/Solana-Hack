// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./LendingNFT.sol";

// import "hardhat/console.sol";

contract BossVault is ReentrancyGuard, Ownable {
    modifier onlyWhenBorrowingAllowed() {
        require(allowBorrowing, "Borrowing is currently disabled");
        _;
    }

    modifier onlyWhenLendingAllowed() {
        require(allowLending, "Lending is currently disabled");
        _;
    }

    struct VaultAsset {
        ERC20 asset;
        string name;
        string symbol;
        uint256 totalDeposited;
        uint256 totalAvailable;
        uint256 totalEarnedInterest;
        uint256 extraLiquidity;
        mapping(address => uint256) deposits;
    }

    struct Vault {
        string name;
        uint256 duration;
        uint256 interestRate;
        uint256 totalDepositedInVault;
        uint256 totalAvailableInVault;
        uint256 totalBorrowedFromVault;
        uint256 totalEarnedInterest;
        uint256 baseRatePerYear;
        uint256 multiplierPerYear;
        mapping(address => VaultAsset) vaultAssets;
        address[] vaultAssetAddresses;
    }

    InvoiceNFT private invoiceNFTInstance;
    // Define the LTV ratio at the contract level. This is set to 70% for this example.
    uint256 private constant LTV_RATIO = 70; // Represented in percentage
    uint256 private SECONDS_IN_A_MONTH = 30 days;
    uint256 private nextLoanID = 1;
    mapping(string => Vault) private vaults;
    string[] private vaultNames;
    mapping(uint256 => string) private vaultsByDuration;

    // Define the mapping to track supported collateral tokens
    mapping(address => bool) private supportedTokens;

    address[] private supportedTokensList;

    // address[] public lenderAddresses;
    // address[] public borrowerAddresses;
    mapping(address => bool) private isLender;
    mapping(address => bool) private isBorrower;

    mapping(address => uint256[]) private userLoans;
    mapping(uint256 => Loan) private loans;
    uint256[] private activeLoans;
    mapping(uint256 => uint256) private activeLoanIndices;

    bool private allowBorrowing;
    bool private allowLending;

    struct Loan {
        address collateralAddress; // Address of the ERC20 token used as collateral
        address loanAssetAddress;
        address borrower;
        uint256 loanID; // Unique identifier for the loan
        uint256 amountUSDC;
        uint256 currentAssetPrice;
        uint256 totalAssetAmount;
        uint256 totalCollateralValue;
        uint256 totalInterest;
        uint256 loanStart;
        uint256 loanEnd;
        uint256 installments;
        uint256 installmentsPaid;
        uint256 interestPerInstallment;
        uint256 liquidationRatio;
        string vaultName;
        bool loanActive;
    }

    event Deposited(
        address indexed user,
        string _vaultName,
        string assetAddress,
        uint256 amount
    );
    event Borrowed(
        address indexed user,
        string collateralName,
        uint256 collateralAmount,
        uint256 loanAmount,
        uint256 interest
    );

    event CollateralAddedInLoan(
        uint256 indexed loanID,
        address indexed borrower,
        address indexed collateralAddress,
        uint256 additionalCollateralAmount,
        uint256 totalCollateralAmount
    );
    event ExtraLiquidityAdded(
        address indexed sender,
        string vaultName,
        address indexed assetAddress,
        uint256 amount
    );

    // Repaid event to include more details
    event Repaid(address indexed borrower, uint256 loanID, uint256 dueAmount);
    event InterestPaid(
        address indexed borrower,
        uint256 installmentNumber,
        uint256 loanID,
        uint256 dueInterest
    );

    event LendingWithdrawn(
        address indexed user,
        uint256 amount,
        string vaultName,
        string assetName
    );
    event AssetAdded(
        string indexed vaultName,
        address indexed assetAddress,
        string assetName,
        string symbol
    );

    event VaultCreated(
        string indexed name,
        uint256 duration,
        uint256 baseRatePerYeartRate,
        uint256 multiplierPerYear
    );

    constructor(
        address _assetAddress,
        address _invoiceNFTAddress,
        address _collateralAddress
    ) {
        require(_invoiceNFTAddress != address(0), "Invalid InvoiceNFT address");
        _transferOwnership(msg.sender);
        invoiceNFTInstance = InvoiceNFT(_invoiceNFTAddress);
        createVault("6_Month", 6, 3, 10);
        addAssetToVault("6_Month", _assetAddress, "USD Token", "USD");
        addSupportedCollateral(_collateralAddress);
    }

    // constructor(
    //     address initialOwner,
    //     address _invoiceNFTAddress
    // ) Ownable(initialOwner) {
    //     require(_invoiceNFTAddress != address(0), "Invalid InvoiceNFT address");
    //     _transferOwnership(initialOwner);
    //     invoiceNFTInstance = InvoiceNFT(_invoiceNFTAddress);
    // }
    // Getter for LTV_RATIO
    function getLTVRatio() external pure returns (uint256) {
        return LTV_RATIO;
    }

    // Getter for SECONDS_IN_A_MONTH
    function getSecondsInAMonth() external view returns (uint256) {
        return SECONDS_IN_A_MONTH;
    }

    // Setter for SECONDS_IN_A_MONTH
    function setSecondsInAMonth(
        uint256 _SECONDS_IN_A_MONTH
    ) external onlyOwner {
        SECONDS_IN_A_MONTH = _SECONDS_IN_A_MONTH;
        // return SECONDS_IN_A_MONTH;
    }

    // Getter for nextLoanID
    function getNextLoanID() external view returns (uint256) {
        return nextLoanID;
    }

    function getVault(
        string memory _vaultName
    )
        external
        view
        returns (
            string memory name,
            uint256 duration,
            uint256 interestRate,
            uint256 totalDepositedInVault,
            uint256 totalAvailableInVault,
            uint256 totalBorrowedFromVault,
            uint256 totalEarnedInterest,
            uint256 baseRatePerYear,
            uint256 multiplierPerYear,
            address[] memory vaultAssetAddresses
        )
    {
        Vault storage v = vaults[_vaultName];
        return (
            v.name,
            v.duration,
            v.interestRate,
            v.totalDepositedInVault,
            v.totalAvailableInVault,
            v.totalBorrowedFromVault,
            v.totalEarnedInterest,
            v.baseRatePerYear,
            v.multiplierPerYear,
            v.vaultAssetAddresses
        );
    }

    function getLoan(uint256 _loanID) external view returns (Loan memory) {
        return loans[_loanID];
    }

    function addExtraLiquidityToVaultAsset(
        string memory _vaultName,
        address assetAddress,
        uint256 amount
    ) external {
        // Require statements can be used for basic input validation (e.g., non-zero amount)
        require(amount > 0, "Cannot add zero liquidity");

        // Access the VaultAsset storage reference
        VaultAsset storage va = vaults[_vaultName].vaultAssets[assetAddress];

        // Transfer the tokens from the sender to this contract
        // The user must first approve this contract to spend at least `amount`
        require(
            ERC20(assetAddress).transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );

        // Update the vault's liquidity information
        va.extraLiquidity += amount;

        // Emit an event, if you have events set up for tracking vault actions
        emit ExtraLiquidityAdded(msg.sender, _vaultName, assetAddress, amount);
    }

    function getVaultAsset(
        string memory _vaultName,
        address assetAddress
    )
        external
        view
        returns (
            address asset,
            string memory name,
            string memory symbol,
            uint256 totalDeposited,
            uint256 totalAvailable,
            uint256 totalEarnedInterest,
            uint256 extraLiquidity
        )
    {
        VaultAsset storage va = vaults[_vaultName].vaultAssets[assetAddress];
        return (
            address(va.asset),
            va.name,
            va.symbol,
            va.totalDeposited,
            va.totalAvailable,
            va.totalEarnedInterest,
            va.extraLiquidity
        );
    }

    // This function returns the list of all vault names.
    function getAllVaultNames() external view returns (string[] memory) {
        return vaultNames;
    }

    // Getter for vaultsByDuration mapping
    function getVaultByDuration(
        uint256 duration
    ) external view returns (string memory) {
        return vaultsByDuration[duration];
    }

    // Getter for supportedTokens mapping
    function isTokenSupported(
        address tokenAddress
    ) external view returns (bool) {
        return supportedTokens[tokenAddress];
    }

    // Getter for isLender mapping
    function isUserLender(address _address) external view returns (bool) {
        return isLender[_address];
    }

    // Getter for isBorrower mapping
    function isUserBorrower(address _address) external view returns (bool) {
        return isBorrower[_address];
    }

    // Getter for userLoans mapping
    function getUserLoans(
        address user
    ) external view returns (uint256[] memory) {
        return userLoans[user];
    }

    function addAssetToVault(
        string memory _vaultName,
        address _assetAddress,
        string memory _name,
        string memory _symbol
    ) public onlyOwner {
        Vault storage userVault = vaults[_vaultName];

        // Ensure the asset doesn't already exist
        require(
            address(userVault.vaultAssets[_assetAddress].asset) == address(0),
            "Asset already exists in the vault"
        );

        userVault.vaultAssets[_assetAddress].asset = ERC20(_assetAddress);
        userVault.vaultAssets[_assetAddress].name = _name;
        userVault.vaultAssets[_assetAddress].symbol = _symbol;
        userVault.vaultAssets[_assetAddress].totalDeposited = 0;
        userVault.vaultAssets[_assetAddress].extraLiquidity = 0;

        userVault.vaultAssetAddresses.push(_assetAddress);

        emit AssetAdded(_vaultName, _assetAddress, _name, _symbol);
    }

    function addLender(address _address) internal {
        if (!isLender[_address]) {
            isLender[_address] = true;
        }
    }

    function addBorrower(address _address) internal {
        if (!isBorrower[_address]) {
            isBorrower[_address] = true;
        }
    }

    function balanceofAssetInContract(
        address _address
    ) public view returns (uint256) {
        return ERC20(_address).balanceOf(address(this));
    }

    function withdrawERC20(
        address tokenAddress,
        address to,
        uint256 amount
    ) external onlyOwner {
        require(ERC20(tokenAddress).transfer(to, amount), "Transfer failed");
    }

    function toggleBorrowing() external onlyOwner {
        allowBorrowing = !allowBorrowing;
    }

    function toggleLending() external onlyOwner {
        allowLending = !allowLending;
    }

    function addCollateral(
        uint256 loanID,
        uint256 additionalCollateral
    ) external {
        Loan storage loan = loans[loanID];

        require(msg.sender == loan.borrower, "Not the loan borrower");
        require(loan.loanActive, "Loan is not active");

        ERC20 collateralToken = ERC20(loan.collateralAddress);
        uint256 allowance = collateralToken.allowance(
            msg.sender,
            address(this)
        );

        require(allowance >= additionalCollateral, "Check the token allowance");

        // Transfer the collateral from the borrower to the contract
        collateralToken.transferFrom(
            msg.sender,
            address(this),
            additionalCollateral
        );

        // Update the total collateral amount
        loan.totalAssetAmount += additionalCollateral;
        // Emit the event
        emit CollateralAddedInLoan(
            loanID,
            msg.sender,
            loan.collateralAddress,
            additionalCollateral,
            loan.totalAssetAmount
        );
    }

    function createVault(
        string memory _vaultName,
        uint256 _duration,
        uint256 _baseRatePerYear,
        uint256 _multiplierPerYear
    ) public onlyOwner {
        // Ensure the vault doesn't already exist
        require(
            bytes(vaults[_vaultName].name).length == 0,
            "Vault already exists"
        );

        Vault storage vault = vaults[_vaultName];
        vault.name = _vaultName;
        vault.duration = _duration;
        vault.baseRatePerYear = _baseRatePerYear * 1e16;
        vault.multiplierPerYear = _multiplierPerYear * 1e15;

        vaultNames.push(_vaultName);
        vaultsByDuration[_duration] = _vaultName;
        emit VaultCreated(
            _vaultName,
            _duration,
            _baseRatePerYear,
            _multiplierPerYear
        );
    }

    // Function to add a token to the supported list
    function addSupportedCollateral(address tokenAddress) public onlyOwner {
        require(tokenAddress != address(0), "Invalid token address");
        require(!supportedTokens[tokenAddress], "Token already supported");
        supportedTokens[tokenAddress] = true;
        supportedTokensList.push(tokenAddress);
    }

    // Function to remove a token from the supported list
    function removeSupportedCollateral(
        address tokenAddress
    ) external onlyOwner {
        require(supportedTokens[tokenAddress], "Token not currently supported");
        supportedTokens[tokenAddress] = false;
        // Remove token from the supportedTokensList array
        for (uint256 i = 0; i < supportedTokensList.length; i++) {
            if (supportedTokensList[i] == tokenAddress) {
                // Swap with the last element
                supportedTokensList[i] = supportedTokensList[
                    supportedTokensList.length - 1
                ];
                // Remove the last element
                supportedTokensList.pop();
                break;
            }
        }
    }

    function getSupportedCollaterals()
        external
        view
        returns (address[] memory)
    {
        return supportedTokensList;
    }

    function getTotalBorrowedFromVault(
        string memory _vaultName
    ) public view returns (uint256) {
        return vaults[_vaultName].totalBorrowedFromVault;
    }

    function getUserLoanIDs(
        address user
    ) public view returns (uint256[] memory) {
        return userLoans[user];
    }

    function getTotalAvailableInVault(
        string memory _vaultName
    ) public view returns (uint256) {
        uint256 totalAvailable = vaults[_vaultName].totalAvailableInVault;
        return totalAvailable;
    }

    function getUtilizationRate(
        string memory _vaultName
    ) public view returns (uint256) {
        uint256 totalBorrows = vaults[_vaultName].totalBorrowedFromVault;
        uint256 totalLiquidity = vaults[_vaultName].totalDepositedInVault;
        if (totalLiquidity == 0) {
            return 0;
        }
        return (totalBorrows * 1e18) / (totalBorrows + totalLiquidity);
    }

    function getAnnualBorrowRate(
        string memory _vaultName
    ) public view returns (uint256) {
        uint256 utilizationRate = getUtilizationRate(_vaultName);
        uint256 baseRate = vaults[_vaultName].baseRatePerYear;
        uint256 multiplier = vaults[_vaultName].multiplierPerYear;

        return baseRate + (utilizationRate * multiplier) / 1e18;
    }

    function getMonthlyBorrowRate(
        string memory _vaultName
    ) public view returns (uint256) {
        uint256 annualBorrowRate = getAnnualBorrowRate(_vaultName);
        return annualBorrowRate / 12;
    }

    function selectBestVault(
        uint256 requestedDurationInMonths
    ) internal view returns (string memory) {
        uint256 roundedDurationInSeconds = ((requestedDurationInMonths + 5) /
            6) *
            6 *
            SECONDS_IN_A_MONTH;
        string memory vaultName = vaultsByDuration[roundedDurationInSeconds];

        require(bytes(vaultName).length > 0, "No suitable vault found");
        return vaultName;
    }

    function _removeActiveLoan(uint256 loanID) internal {
        uint256 loanIndex = activeLoanIndices[loanID];
        uint256 lastLoanID = activeLoans[activeLoans.length - 1];

        activeLoans[loanIndex] = lastLoanID;
        activeLoanIndices[lastLoanID] = loanIndex;

        activeLoans.pop();
        delete activeLoanIndices[loanID];
    }

    function _transferDepositTokens(
        address depositor,
        address assetAddress,
        uint256 amount
    ) internal {
        ERC20 assetToken = ERC20(assetAddress);

        uint256 allowance = assetToken.allowance(depositor, address(this));
        require(allowance >= amount, "Check the asset allowance");

        assetToken.transferFrom(depositor, address(this), amount);
    }

    function _updateVaultState(
        string memory _vaultName,
        address assetAddress,
        uint256 amount
    ) internal {
        Vault storage userVault = vaults[_vaultName];
        VaultAsset storage userAsset = userVault.vaultAssets[assetAddress];

        userAsset.totalDeposited += amount;
        userAsset.totalAvailable += amount;
        userVault.totalDepositedInVault += amount;
        userVault.totalAvailableInVault += amount;
        userAsset.deposits[msg.sender] += amount;
    }

    function _mintDepositNFT(
        address depositor,
        string memory _vaultName,
        address assetAddress,
        uint256 amount
    ) internal {
        vaults[_vaultName].interestRate = getAnnualBorrowRate(_vaultName);

        InvoiceNFT.InvoiceDetails memory details = InvoiceNFT.InvoiceDetails(
            assetAddress,
            amount,
            vaults[_vaultName].interestRate,
            block.timestamp,
            vaults[_vaultName].duration,
            vaults[_vaultName].vaultAssets[assetAddress].name,
            vaults[_vaultName].vaultAssets[assetAddress].symbol,
            _vaultName
        );

        invoiceNFTInstance.mintInvoice(depositor, details);
    }

    function deposit(
        string memory _vaultName,
        address assetAddress,
        uint256 amount
    ) public nonReentrant onlyWhenLendingAllowed {
        require(amount > 0, "Deposit amount must be greater than 0");
        require(vaults[_vaultName].duration != 0, "Vault does not exist");
        require(
            address(vaults[_vaultName].vaultAssets[assetAddress].asset) !=
                address(0),
            "Asset not supported in this vault"
        );

        _transferDepositTokens(msg.sender, assetAddress, amount);
        _updateVaultState(_vaultName, assetAddress, amount);

        _mintDepositNFT(msg.sender, _vaultName, assetAddress, amount);
        addLender(msg.sender);

        emit Deposited(
            msg.sender,
            _vaultName,
            vaults[_vaultName].vaultAssets[assetAddress].name,
            amount
        );
    }

    function withdrawLending(uint256 invoiceID) public nonReentrant {
        // Ensure the caller owns the InvoiceNFT corresponding to their deposit
        require(
            invoiceNFTInstance.ownerOf(invoiceID) == msg.sender,
            "Must own the corresponding InvoiceNFT to withdraw"
        );

        // Get details of the invoice
        InvoiceNFT.InvoiceDetails memory details = invoiceNFTInstance
            .getInvoiceDetails(invoiceID);

        // Check if the deposit duration has elapsed
        require(
            block.timestamp >=
                details.startTime + (details.duration * SECONDS_IN_A_MONTH),
            "Deposit duration has not elapsed"
        );

        // Use the details to identify the vault and asset
        Vault storage userVault = vaults[details.vaultName];
        require(userVault.duration != 0, "Vault does not exist");

        VaultAsset storage userAsset = userVault.vaultAssets[
            details.assetAddress
        ];
        require(
            address(userAsset.asset) != address(0),
            "Asset not supported in this vault"
        );

        uint256 amountToWithdraw = details.amount;

        // Ensure consistency between recorded deposits and NFT details
        require(
            userAsset.deposits[msg.sender] >= amountToWithdraw,
            "Mismatch between NFT details and recorded deposits"
        );

        require(amountToWithdraw > 0, "No funds to withdraw from this vault");

        // Burn the InvoiceNFT
        invoiceNFTInstance.burnInvoice(invoiceID);

        // // Convert duration from months to seconds
        // uint256 durationInSeconds = details.duration * 30 * 24 * 60 * 60;  // Assuming each month is approximately 30 days

        // // Since it's a fixed loan period, the timeSinceDeposit should be equal to the loan duration in seconds
        // uint256 timeSinceDeposit = durationInSeconds;

        // uint256 secondsInAYear = 31536000; // Approximate seconds in a year (365 days)

        // // Calculate interest (using simple interest formula)
        // // Assuming getAnnualBorrowRate() returns the 3% annual rate scaled to 18 decimals
        // uint256 interestRate = getAnnualBorrowRate(details.vaultName);
        // console.log(interestRate);

        // // Calculate the interest earned
        // uint256 interestEarned = (amountToWithdraw * interestRate * timeSinceDeposit)/ ( secondsInAYear / 1e18);
        // console.log(interestEarned);

        // Fetch the monthly borrow rate
        uint256 monthlyBorrowRate = getMonthlyBorrowRate(details.vaultName);

        // Adjust the borrow rate to get the lending rate. E.g., 95% of the borrow rate.
        uint256 lendingRate = (monthlyBorrowRate * 95) / 100; // Adjust this percentage as per your needs

        // Calculate the interest earned for lending using simple interest formula
        // After multiplication, the result has 36 decimals, so we divide by 1e18 to bring it back to 18 decimals
        uint256 monthlyInterestEarned = (amountToWithdraw * lendingRate) / 1e18;

        // Multiply by the number of months to get total interest for the lending period
        uint256 totalInterestEarned = monthlyInterestEarned * details.duration;

        // // Logging the values for debugging
        // console.log(lendingRate);
        // console.log(totalInterestEarned);

        require(
            userAsset.totalEarnedInterest >= totalInterestEarned ||
                userAsset.extraLiquidity >= totalInterestEarned,
            "Not enough funds to pay interest to lender"
        );

        if (userAsset.totalEarnedInterest >= totalInterestEarned) {
            userAsset.totalEarnedInterest -= totalInterestEarned;
        } else if (userAsset.extraLiquidity >= totalInterestEarned) {
            userAsset.extraLiquidity -= totalInterestEarned;
        }
        // Transfer the principal and interest back to the user
        userAsset.asset.transfer(
            msg.sender,
            amountToWithdraw + totalInterestEarned
        );

        // Update the state variables
        userAsset.totalAvailable -= amountToWithdraw;
        userVault.totalAvailableInVault -= amountToWithdraw;
        userAsset.deposits[msg.sender] -= amountToWithdraw;
        // // Transfer the funds back to the user
        // userAsset.asset.transfer(msg.sender, amountToWithdraw);

        // // Update the state variables
        // userAsset.totalAvailable -= amountToWithdraw;
        // userVault.totalAvailableInVault -= amountToWithdraw;
        // userAsset.deposits[msg.sender] -= amountToWithdraw;

        // Emit an event
        emit LendingWithdrawn(
            msg.sender,
            amountToWithdraw,
            details.vaultName,
            details.assetName
        );
    }

    function _transferCollateralForBorrowing(
        Loan memory loan,
        uint256 collateralAmount
    ) internal {
        ERC20 collateralToken = ERC20(loan.collateralAddress);
        uint256 allowance = collateralToken.allowance(
            msg.sender,
            address(this)
        );
        require(allowance >= collateralAmount, "Token allowance insufficient");

        // Transfer Collateral
        collateralToken.transferFrom(
            msg.sender,
            address(this),
            collateralAmount
        );
    }

    function _transferLoanAmountToBorrower(
        Loan memory loan,
        string memory bestVault
    ) internal {
        Vault storage chosenVault = vaults[bestVault];
        VaultAsset storage vaultAsset = chosenVault.vaultAssets[
            address(loan.loanAssetAddress)
        ];

        require(
            vaultAsset.totalAvailable >= loan.amountUSDC,
            "Insufficient funds in the vault"
        );
        require(
            vaultAsset.asset.balanceOf(address(this)) >= loan.amountUSDC,
            "Insufficient funds in the contract"
        );

        vaultAsset.asset.transfer(msg.sender, loan.amountUSDC);
    }

    function _determineLoanAmount(
        uint256 collateralValue,
        uint256 requestedLoanAmount
    ) internal pure returns (uint256) {
        uint256 maxLoanAmount = (collateralValue * LTV_RATIO) / 100;
        require(
            requestedLoanAmount <= maxLoanAmount,
            "Requested loan exceeds allowed amount based on collateral"
        );
        return requestedLoanAmount;
    }

    function _updateVaultForBorrowing(
        Loan memory loan,
        string memory bestVault
    ) internal {
        Vault storage chosenVault = vaults[bestVault];
        VaultAsset storage vaultAsset = chosenVault.vaultAssets[
            address(loan.loanAssetAddress)
        ];

        // Decrement available and increment borrowed amount in the vault and vault asset
        chosenVault.totalAvailableInVault -= loan.amountUSDC;
        vaultAsset.totalAvailable -= loan.amountUSDC;
        chosenVault.totalBorrowedFromVault += loan.amountUSDC;
    }

    function _recordNewLoan(Loan memory loan) internal {
        loans[nextLoanID] = loan;
        userLoans[msg.sender].push(nextLoanID);
        nextLoanID++;

        activeLoans.push(loan.loanID);
        activeLoanIndices[loan.loanID] = activeLoans.length - 1;
    }

    function borrowFunds(
        address collateralTokenAddress,
        uint256 collateralAmount,
        uint256 requestedLoanAmount,
        uint256 collateralValue,
        string calldata _collateralName,
        address assetAddress,
        uint256 duration
    ) public nonReentrant onlyWhenBorrowingAllowed {
        string memory bestVault = selectBestVault(duration);

        require(
            supportedTokens[collateralTokenAddress],
            "Unsupported collateral token"
        );

        uint256 loanAmount = _determineLoanAmount(
            collateralValue,
            requestedLoanAmount
        );
        uint256 monthlyRate = getMonthlyBorrowRate(bestVault);

        // Calculate total interest for the entire loan duration
        // After multiplication, the result has 36 decimals, so we divide by 1e18 to bring it back to 18 decimals
        uint256 totalInterestForWholeDuration = ((monthlyRate *
            loanAmount *
            duration) / 1e18);

        Loan memory newLoan = Loan({
            loanID: nextLoanID,
            borrower: msg.sender,
            amountUSDC: loanAmount,
            currentAssetPrice: collateralValue,
            totalAssetAmount: collateralAmount,
            totalCollateralValue: collateralValue,
            totalInterest: totalInterestForWholeDuration,
            loanStart: block.timestamp,
            installments: duration,
            interestPerInstallment: (monthlyRate * loanAmount) / 1e18,
            installmentsPaid: 0,
            vaultName: bestVault,
            loanEnd: block.timestamp + duration,
            loanActive: true,
            liquidationRatio: LTV_RATIO,
            collateralAddress: collateralTokenAddress,
            loanAssetAddress: assetAddress
        });

        _transferCollateralForBorrowing(newLoan, collateralAmount);
        _transferLoanAmountToBorrower(newLoan, bestVault);
        _updateVaultForBorrowing(newLoan, bestVault);
        _recordNewLoan(newLoan);

        emit Borrowed(
            msg.sender,
            _collateralName,
            collateralAmount,
            loanAmount,
            newLoan.totalInterest
        );
    }

    function payInterestInstallment(uint256 loanID) public nonReentrant {
        Loan storage loan = loans[loanID];

        require(msg.sender == loan.borrower, "Not the borrower of this loan");
        require(loan.loanActive, "No active loan");
        require(
            loan.installmentsPaid < loan.installments,
            "All interest installments already paid"
        );

        uint256 dueInterest = loan.interestPerInstallment;

        Vault storage chosenVault = vaults[loan.vaultName];

        VaultAsset storage vaultAsset = chosenVault.vaultAssets[
            address(loan.loanAssetAddress)
        ];

        require(
            vaultAsset.asset.balanceOf(msg.sender) >= dueInterest,
            "Insufficient funds to pay interest"
        );
        require(
            vaultAsset.asset.allowance(msg.sender, address(this)) >=
                dueInterest,
            "Token allowance insufficient"
        );

        vaultAsset.asset.transferFrom(msg.sender, address(this), dueInterest);

        loan.installmentsPaid++;
        chosenVault.totalEarnedInterest += dueInterest;
        vaultAsset.totalEarnedInterest += dueInterest;
        emit InterestPaid(
            msg.sender,
            loan.installmentsPaid,
            loanID,
            dueInterest
        );
    }

    function repayLoan(uint256 loanID) public nonReentrant {
        Loan storage loan = loans[loanID];

        require(msg.sender == loan.borrower, "Not the borrower of this loan");
        require(loan.loanActive, "No active loan to repay");
        uint256 dueInterest = 0;
        uint256 dueAmount = loan.amountUSDC;
        if (loan.installmentsPaid < loan.installments) {
            dueInterest =
                loan.interestPerInstallment *
                (loan.installments - loan.installmentsPaid);
        }
        dueAmount = dueAmount + dueInterest;

        Vault storage chosenVault = vaults[loan.vaultName];

        VaultAsset storage vaultAsset = chosenVault.vaultAssets[
            address(loan.loanAssetAddress)
        ];
        require(
            vaultAsset.asset.balanceOf(msg.sender) >= dueAmount,
            "Insufficient to repay loan"
        );
        require(
            vaultAsset.asset.allowance(msg.sender, address(this)) >= dueAmount,
            "Token allowance insufficient"
        );

        vaultAsset.asset.transferFrom(msg.sender, address(this), dueAmount);

        loan.loanActive = false;

        ERC20 collateralToken = ERC20(loan.collateralAddress);
        collateralToken.transfer(msg.sender, loan.totalAssetAmount);
        _removeActiveLoan(loanID);
        chosenVault.totalEarnedInterest += dueInterest;
        vaultAsset.totalEarnedInterest += dueInterest;

        chosenVault.totalAvailableInVault += (dueAmount - dueInterest);
        vaultAsset.totalAvailable += (dueAmount - dueInterest);
        emit Repaid(msg.sender, loanID, dueAmount);
        // Repaid event to include more details
    }

    // Ensure that direct ETH transfers are not allowed
    receive() external payable {
        revert("Direct ETH deposits are not allowed.");
    }
}