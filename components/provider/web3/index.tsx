import {
  FunctionComponent,
  createContext,
  useContext,
  useEffect,
  useState,
} from "react";
import { Web3State, createDefaultState } from "./utils";
import { ethers } from "ethers";

const Web3Context = createContext<Web3State>(createDefaultState());

const Web3Provider: FunctionComponent = ({ children }) => {
  const [web3Api, setWeb3Api] = useState<Web3State>(createDefaultState());
  useEffect(() => {
    function initWeb3() {
      const provider = new ethers.BrowserProvider(window.ethereum);

      setWeb3Api({
        ethereum: window.ethereum,
        provider,
        contract: null,
        isLoading: null,
      });
    }
    initWeb3();
  });
  return (
    <Web3Context.Provider value={web3Api}>{children}</Web3Context.Provider>
  );
};

export function useWeb3() {
  return useContext(Web3Context);
}

export default Web3Provider;
