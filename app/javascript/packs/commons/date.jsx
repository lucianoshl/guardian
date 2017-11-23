import React from 'react';
class Date extends React.Component {

    render(){
        var date = new window.Date(1970, 0, 1);
        date.setSeconds(this.props.seconds);

        return <span>
            {date.toString()}
        </span>
    }

}


export default Date;