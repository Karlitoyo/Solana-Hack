import * as React from "react";

const HomeMain = () => (
  <section>
    <div className="box">
      <div className="indicator">
        <span className="indicator-item indicator-center badge badge-primary">
          6 Month Vault
        </span>
        <div className="stats bg-primary text-primary-content">
          <div className="stat">
            <div className="stat-title">Account balance</div>
            <div className="stat-value">$89,400</div>
            <div className="stat-actions">
              <button className="btn btn-sm btn-success">Add funds</button>
            </div>
          </div>

          <div className="stat">
            <div className="stat-title">Current balance</div>
            <div className="stat-value">$89,400</div>
            <div className="stat-actions">
              <button className="btn btn-sm">Withdrawal</button>
              <button
                className="btn btn-sm"
                onClick={async () => {
                  const accounts = await window.ethereum.request({
                    method: "eth_requestAccounts",
                  });
                  console.log(accounts);
                }}
              >
                deposit
              </button>
            </div>
          </div>
        </div>
      </div>
      <div className="indicator">
        <span className="indicator-item indicator-center badge badge-primary">
          12 Month Vault
        </span>
        <div className="stats bg-primary text-primary-content">
          <div className="stat">
            <div className="stat-title">Account balance</div>
            <div className="stat-value">$89,400</div>
            <div className="stat-actions">
              <button className="btn btn-sm btn-success">Add funds</button>
            </div>
          </div>

          <div className="stat">
            <div className="stat-title">Current balance</div>
            <div className="stat-value">$89,400</div>
            <div className="stat-actions">
              <button className="btn btn-sm">Withdrawal</button>
              <button className="btn btn-sm">deposit</button>
            </div>
          </div>
        </div>
      </div>
      <div className="indicator">
        <span className="indicator-item indicator-center badge badge-primary">
          24 Month Vault
        </span>
        <div className="stats bg-primary text-primary-content">
          <div className="stat">
            <div className="stat-title">Account balance</div>
            <div className="stat-value">$89,400</div>
            <div className="stat-actions">
              <button className="btn btn-sm btn-success">Add funds</button>
            </div>
          </div>

          <div className="stat">
            <div className="stat-title">Current balance</div>
            <div className="stat-value">$89,400</div>
            <div className="stat-actions">
              <button className="btn btn-sm">Withdrawal</button>
              <button className="btn btn-sm">deposit</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
);

export default HomeMain;
