import Link from "next/link";
import type { NextPage } from "next";
import { BugAntIcon, MagnifyingGlassIcon, SparklesIcon } from "@heroicons/react/24/outline";
import { MetaHeader } from "~~/components/MetaHeader";
import React, { useState } from 'react';
import { useDebounce } from 'use-debounce';
import { usePrepareContractWrite , useContractWrite, useSendTransaction, usePrepareSendTransaction} from 'wagmi';
import { abi } from './abi';

const Home: NextPage = () => {

  const [formData, setFormData] = useState([
    { address: '', chain: '', amount: '' },
  ]);

  const [distributedData, setDistributedData] = useState([]);

  const chainOptions = [
    'Optimism',
    'Avalanche',
    'Arbitrum',
    'Polygon',
    'BNB',
    'Base',
  ];

  // Mapping of chain names to values
  const chainValues = {
    Optimism: '2664363617261496610',
    Avalanche: '14767482510784806043',
    Arbitrum: '6101244977088475029',
    Polygon: '12532609583862916517',
    BNB: '13264668187771770619',
    Base: '5790810961207155433',
  };

  const handleChange = (index, e) => {
    const { name, value } = e.target;
    const updatedData = [...formData];
    updatedData[index][name] = value;
    setFormData(updatedData);
  };

  const handleChainChange = (index, value) => {
    const updatedData = [...formData];
    updatedData[index].chain = value;
    setFormData(updatedData);
  };

  const addRow = () => {
    setFormData([...formData, { address: '', chain: '', amount: '' }]);
  };

  const handleDistributeClick = () => {
    // Extract values and distribute
    const distributedValues = formData.map((data) => [
      data.address,
      chainValues[data.chain], // Use the mapping to get the value based on the selected chain
      data.amount,
    ]);
    console.log(distributedValues);
    setDistributedData(distributedValues);
  };
    

  const { config, error: prepareError, isError: isPrepareError, } = usePrepareContractWrite({
    address: '0x3b5ed7c3E6725c58926F532e3e97C32EE8576ef1',
    abi: abi,
    functionName: 'addTransactions',
    args: [distributedData],
    
  })
  const { data, error, isError, write  } = useContractWrite(config);

  const { config: splits } = usePrepareContractWrite({
    address: '0x3b5ed7c3E6725c58926F532e3e97C32EE8576ef1',
    abi: abi,
    functionName: 'split',
    
  })
  const { data:mydata, write:split , isSuccess } = useContractWrite(splits);





  return (
    <>
      <MetaHeader />
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5">
          <h1 className="text-center mb-8">
            <span className="block text-2xl mb-2">Welcome to</span>
            <span className="block text-4xl font-bold">Crosschain Payment Distributer</span>
          </h1>
          <p className="text-center text-lg">
            powered by{" "}
            <code className="italic bg-base-300 text-base font-bold max-w-full break-words break-all inline-block">
              chainlink ccip and chainlink automation
            </code>
          </p>
          <p className="text-center text-lg">
            
            <code className="italic bg-base-300 text-base font-bold max-w-full break-words break-all inline-block">
             
            </code>{" "}
       
            <code className="italic bg-base-300 text-base font-bold max-w-full break-words break-all inline-block">
              
            </code>
          </p>
        </div>

        <div className="flex-grow bg-base-300 w-full mt-16 px-8 py-12">
          <div className="flex justify-center items-center gap-12 flex-col sm:flex-row">
            <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
              <BugAntIcon className="h-8 w-8 fill-secondary" />

            </div>
            <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
              <SparklesIcon className="h-8 w-8 fill-secondary" />
              <p>
              Example Usecases
                <Link href="/example-ui" passHref className="link">
                  
                </Link>{" "}
                1. 
              </p>
            </div>
          </div>





          <div>
      <table>
        <thead>
          <tr>
            <th>Address</th>
            <th>Chain</th>
            <th>Amount</th>
          </tr>
        </thead>
        <tbody>
          {formData.map((data, index) => (
            <tr key={index}>
              <td>
                <input
                  type="text"
                  name="address"
                  value={data.address}
                  onChange={(e) => handleChange(index, e)}
                />
              </td>
              <td>
                <select
                  name="chain"
                  value={data.chain}
                  onChange={(e) => handleChainChange(index, e.target.value)}
                >
                  <option value="">Select Chain</option>
                  {chainOptions.map((chain, chainIndex) => (
                    <option key={chainIndex} value={chain}>
                      {chain}
                    </option>
                  ))}
                </select>
              </td>
              <td>
                <input
                  type="text"
                  name="amount"
                  value={data.amount}
                  onChange={(e) => handleChange(index, e)}
                />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <button onClick={addRow}>Add Row</button>
      <button onClick={handleDistributeClick}>Distribute</button>
      
    </div>

    <button style={{ width: '300px', height: '40px' , marginRight: '10px'}} onClick={write}>Store on blockchain</button>
    <button style={{ width: '300px', height: '40px' , marginRight: '10px'}} onClick={split}>Split</button>

    {isSuccess && <div>Transaction: {JSON.stringify(mydata)}</div>}
        </div>
      </div>

    </>
  );
};

export default Home;












  

 


  
 