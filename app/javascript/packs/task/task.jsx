import React from 'react';
import { FormattedDate } from 'react-intl'
import { Row, Col, Container, Button } from 'reactstrap';
import FaPlay from 'react-icons/lib/fa/play';
import FaPause from 'react-icons/lib/fa/pause';

const Task = props =>
  <Container>
    <Row>
      <Col md="9" sm="9">
      <Row>
          <Col md="4" sm="4">{props.handler.match(/Task::(.+?) /)[1]}</Col>
          <Col md="4" sm="4">
            Próxima execução: <FormattedDate
                value={props.run_at}
                hour="numeric"
                minute="numeric"
                second="numeric"
                day="2-digit"
                month="2-digit" />
          </Col>
          <Col md="4" sm="4">
            Ultima execução: <FormattedDate
                value={props.created_at}
                hour="numeric"
                minute="numeric"
                second="numeric"
                day="2-digit"
                month="2-digit" />
          </Col>
        </Row>
      </Col>
      <Col md="3" sm="3">
        <Button color="primary" md="3" sm="3"> <FaPlay /> </Button>{' '}
        <Button color="primary" md="3" sm="3"> <FaPause /> </Button>{' '}
      </Col>
    </Row>
  </Container>

export default Task;