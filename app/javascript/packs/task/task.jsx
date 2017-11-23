import React from 'react';
const Task = props =>
    <div>
        {props.handler.match(/Task::(.+?) /)[1]}
    </div>

export default Task;