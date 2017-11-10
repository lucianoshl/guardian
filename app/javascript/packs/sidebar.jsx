import React from 'react';
import { Link } from 'react-router-dom';

const SidebarItem = props =>
  <Link to="/test">
  {props.name}
  </Link>

const Sidebar = props =>
  <div className="sidebar">
  <SidebarItem name="village" />
  </div>

export default Sidebar;