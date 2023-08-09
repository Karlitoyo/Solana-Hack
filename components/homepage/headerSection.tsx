import * as React from "react";
import Image from "next/image";
import Pepe from "../../public/pepe_bank.jpg";

const HomeHeader = () => (
  <section>
    <div className="header">
      <div>
        <Image className="pepe" src={Pepe} alt="pepe"></Image>
      </div>
      <div className="pl-40 py-40 text-4xl">
        <h1>
          Bank Like A <span className="text-green-600">Boss</span>
        </h1>
      </div>
    </div>
  </section>
);

export default HomeHeader;
