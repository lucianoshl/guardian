import React from 'react';
import { graphql } from 'react-apollo';
import gql from 'graphql-tag';
import Spinner from '../commons/spinner';
import Village from '../village/village';

class TargetHome extends React.Component {

    render(){
        console.log(this.props);
        if (this.props.data.loading) {
            return <Spinner/>
        }

        return <div>
            {this.props.data.villages.map(function(village){
                return <Village key={village.id} {...village} />
            })}
        </div>
    }

}

export default graphql(gql`
query {
    villages {
    id vid name x y state
    }
}
`)(TargetHome);