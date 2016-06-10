/**
 * Created by void on 10/06/16.
 */
var Village = React.createClass({
    propTypes: {
        x: React.PropTypes.number,
        y: React.PropTypes.number
    },

    render: function() {
        return (
            <div>
                <div>Coordinate: {this.props.x}|{this.props.y}</div>
            </div>
        );
    }
});