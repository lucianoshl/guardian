import React from 'react';
import Date from '../commons/date'
const Task = props =>
    <div>
        <p>{props.handler.match(/Task::(.+?) /)[1]}</p>
        <p>Próxima execução: <Date seconds={props.run_at}/></p>
        <p>Ultima execução: <Date seconds={props.created_at}/></p>
        <hr/>
    </div>

export default Task;