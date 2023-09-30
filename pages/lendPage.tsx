import Link from "next/link";
import Layout from "../components/Layout";
import LendHeader from "../components/lendpage/lendPageHeader";
import LendMain from "../components/lendpage/layout/mainSection";
import LendMid from "../components/lendpage/layout/midSection";

const LendPage = () => (
  <Layout>
    <LendHeader />
    <LendMain />
    <LendMid />
  </Layout>
);

export default LendPage;
