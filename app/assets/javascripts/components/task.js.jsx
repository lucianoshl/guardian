var Task = React.createClass({
    propTypes: {
        handler: React.PropTypes.string
    },

    render: function() {
        return (
            <div>
                <div>Handler: {this.props.handler}</div>
            </div>
        );
    }
});