import React from 'react';
import { graphql } from 'react-apollo';
import gql from 'graphql-tag';
import Spinner from '../commons/spinner';
import Village from '../village/village';

import { ListGroup, ListGroupItem } from 'reactstrap';

class TargetHome extends React.Component {

    render(){
        console.log(this.props);
        if (this.props.data.loading) {
            return <Spinner/>
        }
  
        return <ListGroup>
            {this.props.data.villages.map(function(village){
                return <ListGroupItem key={village.id}>
                    <Village {...village} />
                </ListGroupItem>
            })}
        </ListGroup>
    }

}

export default graphql(gql`
query {
    villages {
    id vid name x y state
    }
}
`)(TargetHome);