package org.springframework.samples.petclinic.customers.health;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.samples.petclinic.customers.model.OwnerRepository;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class ServiceHealthIndicator implements HealthIndicator {

    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    private boolean isHealthy = false;

    private OwnerRepository ownerRepo;

    public ServiceHealthIndicator(OwnerRepository ownerRepo) {
        this.ownerRepo = ownerRepo;
        scheduler.scheduleAtFixedRate(() -> {
            checkDatabaseStatus();
            if (isHealthy) {
                scheduler.shutdown();
            }
        }, 10, 5, TimeUnit.SECONDS);
    }

    private void checkDatabaseStatus() {
        boolean databaseReady = ownerRepo.findAll().size() > 0;
        if (databaseReady) {
            isHealthy = true;
            log.info("Database is healthy. Stopping checks.");
        } else {
            log.info("Database is not healthy. Checking again in 5 seconds.");
        }
    }

    @Override
    public Health health() {
        return isHealthy ? Health.up().build() : Health.down().build();
    }
}
