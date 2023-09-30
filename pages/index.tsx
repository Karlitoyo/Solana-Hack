import Link from 'next/link'
import Layout from '../components/Layout'
import HomeHeader from '../components/homepage/headerSection'
import HomeMain from '../components/homepage/layout/mainSection'
import HomeMid from '../components/homepage/layout/midSection'

const IndexPage = () => (
  <Layout title="Home | Next.js + TypeScript Example">
    <HomeHeader />
    <HomeMain />
    <HomeMid />
  </Layout>
)

export default IndexPage
