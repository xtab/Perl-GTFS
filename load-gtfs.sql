/* Required GTFS tables */

CREATE DATABASE IF NOT EXISTS agency_gtfs;
use agency_gtfs;

DROP TABLE IF EXISTS `agency`;

CREATE TABLE `agency` (
    agency_id VARCHAR(255),
    agency_name VARCHAR(255) NOT NULL,
    agency_url VARCHAR(255) NOT NULL,
    agency_timezone VARCHAR(255) NOT NULL,
    agency_lang VARCHAR(255),
    agency_phone VARCHAR(255)
);

DROP TABLE IF EXISTS `stops`;

CREATE TABLE `stops` (
    stop_id VARCHAR(255) NOT NULL PRIMARY KEY,
    stop_code VARCHAR(255),
	stop_name VARCHAR(255) NOT NULL,
	stop_desc VARCHAR(255),
	stop_lat DECIMAL(12,8) NOT NULL,
	stop_lon DECIMAL(12,8) NOT NULL,
	zone_id VARCHAR(255),
    stop_url VARCHAR(255),
    location_type TINYINT,
    parent_station VARCHAR(255),
	KEY `zone_id` (zone_id),
	KEY `stop_lat` (stop_lat),
	KEY `stop_lon` (stop_lon)
);

DROP TABLE IF EXISTS `routes`;

CREATE TABLE `routes` (
    route_id VARCHAR(255) NOT NULL PRIMARY KEY,
	agency_id VARCHAR(255),
	route_short_name VARCHAR(255),
	route_long_name VARCHAR(255),
    route_desc VARCHAR(255),
	route_type TINYINT NOT NULL,
    route_url VARCHAR(255),
    route_color VARCHAR(255),
    route_text_color VARCHAR(255)
);

DROP TABLE IF EXISTS trips;

CREATE TABLE `trips` (
    route_id VARCHAR(255) NOT NULL,
	service_id VARCHAR(255) NOT NULL,
	trip_id VARCHAR(255) NOT NULL PRIMARY KEY,
	trip_headsign VARCHAR(255),
    trip_short_name VARCHAR(255),
	direction_id TINYINT,
	block_id VARCHAR(255),
    shape_id VARCHAR(255),
	pattern_id VARCHAR(255),
    average_speed DECIMAL(5,2),
	KEY `route_id` (route_id),
	KEY `service_id` (service_id),
	KEY `direction_id` (direction_id),
	KEY `block_id` (block_id)
);

DROP TABLE IF EXISTS stop_times;

CREATE TABLE `stop_times` (
    trip_id VARCHAR(255) NOT NULL,
	arrival_time TIME,
	departure_time TIME,
	stop_id VARCHAR(255) NOT NULL,
	stop_sequence SMALLINT UNSIGNED NOT NULL,
    stop_headsign VARCHAR(255),
	pickup_type TINYINT,
	drop_off_type TINYINT,
    shape_dist_traveled DECIMAL(10,4) DEFAULT 0,
	KEY `trip_id` (trip_id),
	KEY `stop_id` (stop_id),
	KEY `stop_sequence` (stop_sequence),
	KEY `pickup_type` (pickup_type),
	KEY `drop_off_type` (drop_off_type)
);

DROP TABLE IF EXISTS calendar;

CREATE TABLE `calendar` (
    service_id VARCHAR(255) NOT NULL PRIMARY KEY,
	monday TINYINT NOT NULL,
	tuesday TINYINT NOT NULL,
	wednesday TINYINT NOT NULL,
	thursday TINYINT NOT NULL,
	friday TINYINT NOT NULL,
	saturday TINYINT NOT NULL,
	sunday TINYINT NOT NULL,
	start_date DATE NOT NULL,	
	end_date DATE NOT NULL
);

/* Optional GTFS tables */

DROP TABLE IF EXISTS calendar_dates;

CREATE TABLE `calendar_dates` (
    service_id VARCHAR(255) NOT NULL,
    `date` DATE NOT NULL,
    exception_type TINYINT NOT NULL,
    KEY `service_id` (service_id),
    KEY `exception_type` (exception_type)    
);

DROP TABLE IF EXISTS fare_attributes;

CREATE TABLE fare_attributes (
    fare_id VARCHAR(255) NOT NULL,
    price VARCHAR(255) NOT NULL,
    currency_type VARCHAR(255) NOT NULL,
    payment_method TINYINT NOT NULL,
    transfers TINYINT,
    transfer_duration MEDIUMINT UNSIGNED
);

DROP TABLE IF EXISTS fare_rules;

CREATE TABLE fare_rules (
    fare_id VARCHAR(255) NOT NULL,
    route_id VARCHAR(255),
    origin_id VARCHAR(255),
    destination_id VARCHAR(255),
    contains_id VARCHAR(255)
);

DROP TABLE IF EXISTS shapes;

CREATE TABLE shapes (
    shape_id VARCHAR(255) NOT NULL,
    shape_pt_lat DECIMAL(12,8) NOT NULL,
    shape_pt_lon DECIMAL(12,8) NOT NULL,
    shape_pt_sequence SMALLINT UNSIGNED NOT NULL, 
    shape_dist_traveled DECIMAL(10,4)
);

DROP TABLE IF EXISTS frequencies;

CREATE TABLE frequencies (
    trip_id VARCHAR(255) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    headway_secs MEDIUMINT NOT NULL
);

DROP TABLE IF EXISTS transfers;

CREATE TABLE transfers (
    from_stop_id VARCHAR(255) NOT NULL,
    to_stop_id VARCHAR(255) NOT NULL,
    transfer_type TINYINT NOT NULL,
    min_transfer_time MEDIUMINT NOT NULL
);

/* non-GTFS standard tables go here */

DROP TABLE IF EXISTS patterns;

CREATE TABLE `patterns` (
	route_id VARCHAR(255),
	pattern_id VARCHAR(255),
	stop_sequence SMALLINT UNSIGNED,
	stop_id VARCHAR(255),
    distance DECIMAL(10,4) UNSIGNED
);
