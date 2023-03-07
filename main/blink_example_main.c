/* Blink Example

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.
*/
#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "esp_log.h"
#include "sdkconfig.h"

static const char *TAG = "example";

/* Use project configuration menu (idf.py menuconfig) to choose the GPIO to blink,
   or you can edit the following line and set a number here.
*/
#define BLINK_GPIO CONFIG_BLINK_GPIO

static uint8_t s_led_state = 0;


static void blink_led(void)
{
    /* Set the GPIO level according to the state (LOW or HIGH)*/
    gpio_set_level(BLINK_GPIO, s_led_state);
}

static void configure_led(void)
{
    ESP_LOGI(TAG, "Example configured to blink GPIO LED!");
    gpio_reset_pin(BLINK_GPIO);
    /* Set the GPIO as a push/pull output */
    gpio_set_direction(BLINK_GPIO, GPIO_MODE_OUTPUT);
}


void app_main(void)
{

    /* Configure the peripheral according to the LED type */
    configure_led();

    while (1) {
        /* Toggle the LED state */
        s_led_state = 1;
        blink_led();
        ESP_LOGI(TAG, "Turning the LED %s", s_led_state == true ? "ON" : "OFF");
        vTaskDelay(1000 / portTICK_PERIOD_MS);

        s_led_state = 0;
        blink_led();
        ESP_LOGI(TAG, "Turning the LED %s", s_led_state == true ? "ON" : "OFF");
        vTaskDelay(10000 / portTICK_PERIOD_MS);
    }
}
