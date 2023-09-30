import * as React from "react";

const BorrowMain = () => (
  <section>
    <div className="box">
      <div className="indicator">
        <span className="indicator-item indicator-center badge badge-primary">
          6 Month Vault
        </span>
        <div className="stats bg-primary text-primary-content">
          <div className="stat">
            <div className="stat-title text-center">Vault balance</div>
            <div className="stat-value">$9,400</div>
            <div className="stat-actions">
              <div className="text-center">
                <div
                  className="radial-progress text-error"
                  style={{ "--value": 50 }}
                >
                  50%
                </div>
              </div>
            </div>
          </div>

          <div className="stat">
            <div className="stat-title text-center">Withdraw Amount</div>
            <div className="join join-vertical lg:join-horizontal">
              <input
              type="number"
              placeholder="Type here"
              className="input input-bordered input-info w-full max-w-xs join-item"
              />
              <span className="btn join-item">USDC</span>
            </div>
            <div className="stat-actions text-center">
              <button
                className="btn btn-sm"
                onClick={async () => {
                  const accounts = await window.ethereum.request({
                    method: "eth_requestAccounts",
                  });
                  console.log(accounts);
                }}
              >
                Withdraw
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
            <div className="stat-title text-center">Vault balance</div>
            <div className="stat-value">$70,000</div>
            <div className="stat-actions">
              <div className="text-center">
                <div
                  className="radial-progress text-warning"
                  style={{ "--value": 75 }}
                >
                  75%
                </div>
              </div>
            </div>
          </div>

          <div className="stat">
            <div className="stat-title text-center">Withdraw Amount</div>
            <div className="join join-vertical lg:join-horizontal">
              <input
              type="number"
              placeholder="Type here"
              className="input input-bordered input-info w-full max-w-xs join-item"
            />
              <span className="btn join-item">USDC</span>
            </div>
            <div className="stat-actions text-center">
              <button className="btn btn-sm">Withdraw</button>
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
            <div className="stat-title text-center">Vault balance</div>
            <div className="stat-value">$89,400</div>
            <div className="stat-actions">
              <div className="text-center">
                <div
                  className="radial-progress text-success"
                  style={{ "--value": 100 }}
                >
                  100%
                </div>
              </div>
            </div>
          </div>

          <div className="stat">
            <div className="stat-title text-center">Withdraw Amount</div>
            <div className="join join-vertical lg:join-horizontal">
              <input
              type="number"
              placeholder="Type here"
              className="input input-bordered input-info w-full max-w-xs join-item"
              disabled
            />
              <span className="btn join-item">USDC</span>
            </div>
            <div className="stat-actions text-center">
              <button className="btn btn-sm">Withdraw</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
);

export default BorrowMain;
