import React, { ReactNode } from "react";
import Link from "next/link";
import Head from "next/head";
import { NextPage } from "next";
import { useWeb3 } from "@providers/web3";
import { useAccount } from "@hooks";

type Props = {
  children?: ReactNode;
  title?: string;
};

const Layout: NextPage = ({ children, title = "BankBoss" }: Props) => {
  const { data } = useAccount("Random");
  console.log(data);
  return (
    <div>
      <Head>
        <title>{title}</title>
        <meta charSet="utf-8" />
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>
      <header>
        <div className="navbar bg-base-100">
          <div className="navbar-start">
            <div className="dropdown">
              <label tabIndex={0} className="btn btn-ghost lg:hidden">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M4 6h16M4 12h8m-8 6h16"
                  />
                </svg>
              </label>
              <ul
                tabIndex={0}
                className="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52"
              >
                <li>
                  <Link href="/">Home</Link> {""}
                </li>
                <li>
                  <Link href="/lendPage">Lend</Link> {""}
                </li>
                <li>
                  <Link href="/borrowPage">Borrow</Link> {""}
                </li>
              </ul>
            </div>
            <a className="btn btn-ghost normal-case text-xl">BankBoss</a>
          </div>
          <div className="navbar-center hidden lg:flex">
            <ul className="menu menu-horizontal px-1">
              <li>
                <Link href="/">Home</Link> {""}
              </li>
              <li>
                <Link href="/lendPage">Lend</Link> {""}
              </li>
              <li>
                <Link href="/borrowPage">Borrow</Link> {""}
              </li>
            </ul>
          </div>
          <div className="navbar-end">
            <button className="btn btn-ghost normal-case text-xl">
              Connect Wallet
            </button>
          </div>
        </div>
      </header>
      {children}
      <hr />

      <footer className="bg-white rounded-lg shadow m-4 dark:bg-gray-800">
        <div className="w-full mx-auto max-w-screen-xl p-4 md:flex md:items-center md:justify-between">
          <span className="text-sm text-gray-500 sm:text-center dark:text-gray-400">
            © 2023{" "}
            <a href="" className="hover:underline">
              BossBank™
            </a>
            . All Rights Reserved.
          </span>
          <ul className="flex flex-wrap items-center mt-3 text-sm font-medium text-gray-500 dark:text-gray-400 sm:mt-0">
            <li>
              <a href="#" className="mr-4 hover:underline md:mr-6 ">
                About
              </a>
            </li>
            <li>
              <a href="#" className="mr-4 hover:underline md:mr-6">
                Privacy Policy
              </a>
            </li>
            <li>
              <a href="#" className="mr-4 hover:underline md:mr-6">
                Licensing
              </a>
            </li>
            <li>
              <a href="#" className="hover:underline">
                Contact
              </a>
            </li>
          </ul>
        </div>
      </footer>
    </div>
  );
};

export default Layout;
