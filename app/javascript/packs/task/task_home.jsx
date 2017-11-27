import React from 'react';
import { graphql } from 'react-apollo';
import gql from 'graphql-tag';
import Spinner from '../commons/spinner';
import Task from './task';

import { ListGroup, ListGroupItem } from 'reactstrap';

class TaskHome extends React.Component {

  render(){
    if (this.props.data.loading) {
      return <Spinner/>
    }

    return <ListGroup>
      {this.props.data.tasks.map(function(task){
        return <ListGroupItem key={task.id}>
          <Task {...task} />
        </ListGroupItem>
      })}
    </ListGroup>
  }

}

export default graphql(gql`
{tasks {
  id handler run_at created_at last_error locked_by 
}}
`)(TaskHome);