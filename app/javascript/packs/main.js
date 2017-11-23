import React from 'react'
import ReactDOM from 'react-dom'

import 'bootstrap/dist/css/bootstrap.css';
import '../styles/theme.sass';

import { ApolloProvider } from 'react-apollo';
import { ApolloClient } from 'apollo-client';
import { HttpLink } from 'apollo-link-http';
import { InMemoryCache } from 'apollo-cache-inmemory';

const client = new ApolloClient({
  link: new HttpLink(),
  cache: new InMemoryCache()
});


import PropTypes from 'prop-types'
import Application from './application'
import {
  BrowserRouter as Router,
} from 'react-router-dom'

import { IntlProvider, addLocaleData } from 'react-intl';
import pt from 'react-intl/locale-data/pt';

addLocaleData([...pt]);

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <IntlProvider locale="pt">
      <ApolloProvider client={client}>
        <Router>
          <Application />
        </Router>
      </ApolloProvider>
    </IntlProvider>,
    document.body.appendChild(document.createElement('div')),
  )
})
