import React, {useEffect} from "react";
import ReactDOM from "react-dom"
import App from "./App";
import HomePage from "./HomePage";

import {BrowserRouter as Router, Route, Link} from "react-router-dom";
import Web3 from "web3";
import RegisterPage from "./Register";


class Login extends React.Component {

    handleLogin = () => {
        // routing jump
        this.meta()
        this.props.history.push('/home')
    }

    // Call metaMask
    meta = () => {
        window.ethereum.enable()
            .then(() => {
                const web3 = new Web3(window.web3.currentProvider)
                console.log(web3)
            })
    }

    render() {
        return (
            <div>
                <p>
                    This is the login page!!
                </p>
                <button onClick={this.handleLogin}>
                    Hit me to Login to meta mask~
                </button>
            </div>
        )
    }
}


const Home = props => {
    const handleBack = () => {
        // go(-1) indicates to go to the last page
        props.history.go(-1)
    }
    return (
        <div>
            <h2>
                This is the home page
                <HomePage />
            </h2>
            <button onClick={handleBack}>Return to the login page~</button>
        </div>
    )
}

const Register = props => {
    const handleBack = () => {
        // go(-1) indicates to go to the last page
        props.history.go(-1)
    }
    return (
        <div>
            <h2>
                This is the Register page
                <RegisterPage />
            </h2>
            <button onClick={handleBack}>Return to the login page~</button>
        </div>
    )

}


const AppLogin = () => (
    <Router>
        <div>
            <h1>
                Supply Chain Demo:
            </h1>
            <Link to="/login">
                Go to the login page
            </Link>
            <Route path="/login" component={Login}/>
            <Route path="/home" component={Home}/>
            <Route path="/register" component={Register} />
        </div>
    </Router>
)

export default AppLogin