package org.springframework.samples.petclinic.visits.service;

import java.util.Date;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.samples.petclinic.visits.entities.VisitRequest;
import org.springframework.samples.petclinic.visits.entities.VisitResponse;
import org.springframework.samples.petclinic.visits.model.Visit;
import org.springframework.samples.petclinic.visits.model.VisitRepository;
import org.springframework.stereotype.Component;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@ConditionalOnProperty(name = "spring.jms.servicebus.enabled", havingValue = "true")
@Component
@Slf4j
@RequiredArgsConstructor
public class VisitsReceiver {
    private final VisitRepository visitsRepository;

    private final JmsTemplate jmsTemplate;

    @Value("${spring.jms.queue.visits-requests:visits-requests}")
    private String requestQueueName;

    @Value("${spring.jms.queue.visits-responses:visits-confirmations}")
    private String confirmationsQueueName;

    @JmsListener(destination = "#{@QueueConfig.visitsRequestsQueue}")
    void receiveVisitRequests(VisitRequest visitRequest) {
        log.info("Received message: {}", visitRequest.getMessage());
        try {
            Visit visit = new Visit(null, new Date(), visitRequest.getMessage(),
                visitRequest.getPetId());
            visitsRepository.save(visit);
            jmsTemplate.convertAndSend(confirmationsQueueName, new VisitResponse(visitRequest.getRequestId(), true, "Your visit request has been accepted"));
        } catch (Exception ex) {
            log.error("Error saving visit: {}", ex.getMessage());
            jmsTemplate.convertAndSend(confirmationsQueueName, new VisitResponse(visitRequest.getRequestId(), false, ex.getMessage()));
        }
    }

}
