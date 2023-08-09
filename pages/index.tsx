import Link from 'next/link'
import Layout from '../components/Layout'
import HomeHeader from '../components/homepage/headerSection'
import HomeMain from '../components/homepage/layout/mainSection'

const IndexPage = () => (
  <Layout title="Home | Next.js + TypeScript Example">
    <HomeHeader />
    <HomeMain />
  </Layout>
)

export default IndexPage
