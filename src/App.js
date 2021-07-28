import './App.css';
import {useEffect} from "react";
import Web3 from 'web3'

function App() {

    useEffect(()=>{
        window.ethereum.enable()
            .then(()=>{
            const web3 = new Web3(window.web3.currentProvider)
                console.log(web3)
        })
    }, [])

    const sendEther = async () => {
        const web3 = new Web3(window.web3.currentProvider)
        const [account] = await web3.eth.getAccounts()
        console.log(account)

        const tx =await web3.eth.sendTransaction({
            from: account,
            to: '0xF8bb063045eCF880876306693C967810C5F84C28',
            value: '1000000000000000000'
        })
        console.log(tx)
    }

    return (
        <div className="App">

            <button onClick={sendEther}>
                Initialize trade.....
            </button>
        </div>
    );
}

export default App;
