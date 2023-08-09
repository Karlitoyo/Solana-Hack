import * as React from "react";

const HomeMain = () => (
  <section className="mainPageSection">
    <div className="stats bg-primary text-primary-content main-page-content text-center container">
      <div className="stat main-page-indicators">
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

      <div className="stat">
        <div className="stat-title">Current balance</div>
        <div className="stat-value">$89,400</div>
        <div className="stat-actions">
          <button className="btn btn-sm">Withdrawal</button>
          <button className="btn btn-sm">
            <a href="#my_modal_8">deposit</a>
          </button>
        </div>
      </div>

      <div className="stat">
        <div className="stat-title">Current balance</div>
        <div className="stat-value">$89,400</div>
        <div className="stat-actions">
          <button className="btn btn-sm">Withdrawal</button>
          <button className="btn btn-sm">
            <a href="#my_modal_8">deposit</a>
          </button>{" "}
        </div>
      </div>

      <div className="modal" id="my_modal_8">
        <div className="modal-box">
          <h3 className="font-bold text-lg">Hello!</h3>
          <p className="py-4">This modal works with anchor links</p>
          <div className="modal-action">
            <a href="#" className="btn">
              Yay!
            </a>
          </div>
        </div>
      </div>
    </div>
  </section>
);

export default HomeMain;
