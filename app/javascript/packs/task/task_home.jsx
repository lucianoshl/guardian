import React from 'react';
import { graphql } from 'react-apollo';
import gql from 'graphql-tag';
import Spinner from '../commons/spinner';
import Task from './task';

class TaskHome extends React.Component {

    render(){
        if (this.props.data.loading) {
            return <Spinner/>
        }

        return <div>
            {this.props.data.tasks.map(function(task){
                return <Task key={task.id} {...task} />
            })}
        </div>
    }

}

export default graphql(gql`
{tasks {
    attempts handler id last_error locked_by priority queue
  }}
`)(TaskHome);