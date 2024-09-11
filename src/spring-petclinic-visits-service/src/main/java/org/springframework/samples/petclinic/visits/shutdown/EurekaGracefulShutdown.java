package org.springframework.samples.petclinic.visits.shutdown;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.netflix.eureka.EurekaInstanceConfigBean;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class EurekaGracefulShutdown {

    @Autowired
    private EurekaInstanceConfigBean eurekaInstanceConfig;

    private static final String STATUS_DOWN = "DOWN";

    // The wait time shoud be the maximum time for all eureka clients to refresh their cache, consider
    // eureka client config: eureka.client.registryFetchIntervalSeconds and ribbon.ServerListRefreshInterval
    // eureka server eureka.server.responseCacheUpdateIntervalMs
    private static final int WAIT_SECONDS = 30;

    @EventListener
    public void onShutdown(ContextClosedEvent event) {
        log.info("Caught shutdown event");
        log.info("De-register instance from eureka server");
        eurekaInstanceConfig.setStatusPageUrl(STATUS_DOWN);

        // Wait to continue serve traffic before all Eureka clients refresh their cache
        try {
            log.info("wait {} seconds before shutting down the application", WAIT_SECONDS);
            Thread.sleep(1000 * WAIT_SECONDS); 
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        log.info("Shutdown the application now.");
    }
}
