import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import Application from './application'
import {
  BrowserRouter as Router,
} from 'react-router-dom'


document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Router>
      <Application />
    </Router>,
    document.body.appendChild(document.createElement('div')),
  )
})
