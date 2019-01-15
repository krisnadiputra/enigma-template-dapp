import React, { Component } from "react";
import Polls from "./Polls";
import Grid from "@material-ui/core/Grid";
import Paper from "@material-ui/core/Paper";
import Select from "@material-ui/core/Select";
import MenuItem from "@material-ui/core/MenuItem";
import List from "@material-ui/core/List";
import PropTypes from "prop-types";
import { withStyles } from "@material-ui/core/styles";

const styles = theme => ({
	root: {
		flexGrow: 1
	},
	paper: {
		color: "primary"
	}
});

class VotingWrapper extends Component {
	constructor(props) {
		super(props);
		this.state = {
			curAccount: 0
		};
		this.changeTokenBalance = this.changeTokenBalance.bind(this);
		this.changeStakedToken = this.changeStakedToken.bind(this);
		this.accountChange = this.accountChange.bind(this);
	}

	/*
  	Update user account
  	*/
	async accountChange(event) {
		let curAccount = event.target.value;
		this.setState({ curAccount });
	}

	/*
  	Callback to change token balance for user
  	*/
	changeTokenBalance(tokenBalance) {
		this.setState({ tokenBalance });
	}

	/*
  	Callback to change staked token balance for user
  	*/
	changeStakedToken(stakedTokenBalance) {
		this.setState({ stakedTokenBalance });
	}

	render() {
		const { classes } = this.props;
		return (
			<div>
				<Grid item xs={12}>
					<Paper>
						<div id="dashboard">
							<h3> Dashboard: </h3>
							<List
								style={{
									display: "flex",
									flexDirection: "row"
								}}
							>
								<Grid item xs={4}>
									<label>
										Current Ganache Account:
										<Select
											value={this.state.curAccount}
											onChange={this.accountChange}
											style={{ marginLeft: "10px" }}
										>
											<MenuItem value={0}>0</MenuItem>
											<MenuItem value={1}>1</MenuItem>
											<MenuItem value={2}>2</MenuItem>
											<MenuItem value={3}>3</MenuItem>
											<MenuItem value={4}>4</MenuItem>
											<MenuItem value={5}>5</MenuItem>
											<MenuItem value={6}>6</MenuItem>
											<MenuItem value={7}>7</MenuItem>
											<MenuItem value={8}>8</MenuItem>
										</Select>
									</label>
								</Grid>
							</List>
						</div>
					</Paper>
				</Grid>
				<br />
				<Grid container className={classes.root} spacing={16}>
					<Grid item xs={12}>
						<Paper className={classes.paper}>
							<Polls
								enigmaSetup={this.props.enigmaSetup}
								voting={this.props.voting}
								tokenBalance={this.state.tokenBalance}
								curAccount={this.state.curAccount}
							/>
						</Paper>
					</Grid>
				</Grid>
			</div>
		);
	}
}

VotingWrapper.propTypes = {
	classes: PropTypes.object.isRequired
};

export default withStyles(styles)(VotingWrapper);
