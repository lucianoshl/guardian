import React from 'react';
import { Badge , Container, Row, Col, ListGroupItemHeading, ListGroupItemText } from 'reactstrap';

const Village = props =>
  <Container>
    <Row>
      <Col>
        <ListGroupItemHeading>
          {props.name}
          <Badge color="primary" className="float-right">{props.state}</Badge>
        </ListGroupItemHeading>
        <ListGroupItemText>
        </ListGroupItemText>
      </Col>
    </Row>
  </Container>

export default Village;