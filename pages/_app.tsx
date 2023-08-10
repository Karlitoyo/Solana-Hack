import "tailwindcss/tailwind.css";
import "../styles/styles.css";
import { Web3Provider } from "@providers";
import { AppProps } from "next/app";

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <>
      <Web3Provider>
        <Component {...pageProps} />
      </Web3Provider>
    </>
  );
}

export default MyApp;
