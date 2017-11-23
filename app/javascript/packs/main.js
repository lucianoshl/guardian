import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import Application from './application'
import {
  BrowserRouter as Router,
} from 'react-router-dom'

import { ApolloProvider } from 'react-apollo';

import { ApolloClient } from 'apollo-client';
import { HttpLink } from 'apollo-link-http';
import { InMemoryCache } from 'apollo-cache-inmemory';

import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';

const client = new ApolloClient({
  link: new HttpLink(),
  cache: new InMemoryCache()
});

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <MuiThemeProvider>
      <ApolloProvider client={client}>
        <Router>
          <Application />
        </Router>
      </ApolloProvider>
    </MuiThemeProvider>,
    document.body.appendChild(document.createElement('div')),
  )
})
