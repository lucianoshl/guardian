import React from 'react';
import VillageHome from './village/village_home';
import TaskHome from './task/task_home';
import TargetHome from './target/target_home';
import { Link, Route } from 'react-router-dom';
import { Container } from 'reactstrap';

const Application = props =>
  <Container fluid={true}>
    <div className="row">
      <nav className="col-sm-3 col-md-2 hidden-xs-down bg-faded sidebar">
        <ul className="nav nav-pills flex-column">
          {/* <li className="nav-item">
            <a className="nav-link active" href="#">Overview <span className="sr-only">(current)</span></a>
          </li> */}
          <li className="nav-item">
            <Link to="/" className="nav-link">Tasks</Link>
          </li>
          <li className="nav-item">
            <Link to="/villages" className="nav-link">Villages</Link>
          </li>
          <li className="nav-item">
            <Link to="/targets" className="nav-link" >Targets</Link>
          </li>
        </ul>
      </nav>
      <div className="col-sm-9 offset-sm-3 col-md-10 offset-md-2 pt-3">
        <Route exact path="/" component={TaskHome}/>
        <Route exact path="/villages" component={VillageHome}/>
        <Route exact path="/targets" component={TargetHome}/>
      </div>
    </div>
  </Container>

export default Application;