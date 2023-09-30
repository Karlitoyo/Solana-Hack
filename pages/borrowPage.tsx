import Link from "next/link";
import Layout from "../components/Layout";
import BorrowHeader from "../components/borrowpage/borrowPageHeader";
import BorrowMain from "../components/borrowpage/layout/mainSection";

const BorrowPage = () => (
  <Layout title="Borrow Page">
    <BorrowHeader />
    <BorrowMain />
  </Layout>
);

export default BorrowPage;
