import React from 'react';
import { FormattedDate } from 'react-intl'

const Task = props =>
    <div>
        <p>{props.handler.match(/Task::(.+?) /)[1]}</p>
        <p>
            Próxima execução: <FormattedDate
                    value={props.run_at}
                    hour="numeric"
                    minute="numeric"
                    second="numeric"
                    day="2-digit"
                    month="2-digit" />
        </p>
        <p>
            Ultima execução: <FormattedDate
                    value={props.created_at}
                    hour="numeric"
                    minute="numeric"
                    second="numeric"
                    day="2-digit"
                    month="2-digit" />
        </p>
    </div>

export default Task;