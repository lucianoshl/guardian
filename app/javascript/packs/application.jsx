import React from 'react';
import VillageHome from './village/village_home';
import TaskHome from './task/task_home';
import TargetHome from './target/target_home';
import { Link, Route } from 'react-router-dom'

const Application = props =>
  <div className="app">
    <div className="sidebar">
      <ul>
        <li><Link to="/">Tasks</Link></li>
        <li><Link to="/villages">Villages</Link></li>
        <li><Link to="/targets">Targets</Link></li>
      </ul>
    </div>
    <div className="main-container">
      <Route exact path="/" component={TaskHome}/>
      <Route exact path="/villages" component={VillageHome}/>
      <Route exact path="/targets" component={TargetHome}/>
    </div>
  </div>

export default Application;