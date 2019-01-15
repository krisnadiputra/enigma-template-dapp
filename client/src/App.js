import React, { Component } from "react";
import getContractInstance from "./utils/getContractInstance";
import EnigmaSetup from "./utils/getEnigmaSetup";
import { Container, Message } from "semantic-ui-react";
import Header from "./Header";
import "./App.css";
import VotingWrapper from "./VotingWrapper";
// Material UI Components
import PropTypes from "prop-types";
import { withStyles } from "@material-ui/core/styles";
import votingContractDefinition from "./contracts/Voting.json";

const styles = theme => ({
  root: {
    flexGrow: 1
  },
  paper: {
    color: "primary"
  }
});

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      enigmaSetup: null,
      voting: null
    };
  }

  componentDidMount = async () => {
    let enigmaSetup = new EnigmaSetup();
    await enigmaSetup.init();
    const voting = await getContractInstance(
      enigmaSetup.web3,
      votingContractDefinition
    );
    this.setState({ voting, enigmaSetup });
  };

  render() {
    const { classes } = this.props;

    if (!this.state.enigmaSetup) {
      return (
        <div className="App">
          <Header />
          <Message color="red">Enigma setup still loading...</Message>
        </div>
      );
    } else if (!this.state.enigmaSetup.complete) {
      return (
        <div className="App">
          <Header />
          <Message color="red">Enigma setup still loading...</Message>
        </div>
      );
    } else {
      return (
        <div className="App">
          <Header />
          <br />
          <Container>
            <VotingWrapper
              enigmaSetup={this.state.enigmaSetup}
              voting={this.state.voting}
            />
          </Container>
        </div>
      );
    }
  }
}

App.propTypes = {
  classes: PropTypes.object.isRequired
};

export default withStyles(styles)(App);
