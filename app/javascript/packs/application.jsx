import React from 'react';
import VillageHome from './village/village_home';
import TaskHome from './task/task_home';
import TargetHome from './target/target_home';
import { Link, Route } from 'react-router-dom'

import AppBar from 'material-ui/AppBar';

import Drawer from 'material-ui/Drawer';
import MenuItem from 'material-ui/MenuItem';

const Application = props =>
  <div className="app">
    <AppBar
      title="Title"
      iconClassNameRight="muidocs-icon-navigation-expand-more"
    />
    <Drawer open={true} swipeAreaWidth={100}>
      <MenuItem>Menu Item</MenuItem>
      <MenuItem>Menu Item 2</MenuItem>
    </Drawer>
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