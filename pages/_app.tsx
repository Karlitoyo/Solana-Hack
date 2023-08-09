import "tailwindcss/tailwind.css";
import "../styles/styles.css";
import { useEffect, useState } from "react";
import Web3 from "web3";

function MyApp({ Component, pageProps }) {
  const [web3Api, setWeb3Api] = useState({
    provider: null,
    web3: null,
  });

  const [account, setAccount] = useState(null);

  useEffect(() => {
    const provider = async () => {
      let provider = null;

      if (window.ethereum) {
        provider = window.ethereum;
        try {
          await provider.request({ method: "eth_requestAccounts" });
        } catch {
          console.error("User Denied Access!");
        }
      } else if (window.Web3Eth) {
        provider = window.web3.currentProvider;
      } else if (!process.env.production) {
        provider = new Web3.providers.HttpProvider("http://localhost:7545");
      }

      setWeb3Api({
        web3: new Web3(provider),
        provider,
      });
    };

    provider();
  }, []);

  useEffect(() => {
    const getAccount = async () => {
      const accounts = await web3Api.web3.eth.getAccounts();
      setAccount(accounts[0]);
    };

    web3Api.web3 && getAccount();
  }, [web3Api.web3]);

  return <Component {...pageProps} />;
}

export default MyApp;
