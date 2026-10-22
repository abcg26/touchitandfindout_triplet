#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <SoftwareSerial.h>

#define BT_RX 2
#define BT_TX 3
#define BT_STATE 4
#define BUZZER_PIN 9

float MOVE_THRESHOLD = 2.0;
unsigned long ALARM_DURATION = 5000;

SoftwareSerial bluetooth(BT_RX, BT_TX);
Adafruit_MPU6050 mpu;

bool isArmed = false;
bool isAlarmActive = false;
int previousConnectionState = -1;
unsigned long alarmStartTime = 0;
unsigned long lastTelemetryTime = 0;

// Loud simple alarm pattern: beep beep
const int alarmFreq = 2000;   // high pitched beep
const int pauseBetweenBeep = 120;

void setup() {
  Serial.begin(9600);
  bluetooth.begin(9600);

  pinMode(BT_STATE, INPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  // startup chirp
  tone(BUZZER_PIN, 1800, 150);
  delay(200);

  if (!mpu.begin()) {
    Serial.println("Could not find MPU6050 sensor!");
    while (1) {
      delay(10);
    }
  }

  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);

  Serial.println("=== SYSTEM INITIALIZED ===");
  bluetooth.println("STATUS:DISARMED");
}

void loop() {
  int currentConnectionState = digitalRead(BT_STATE);

  if (currentConnectionState != previousConnectionState) {
    if (currentConnectionState == HIGH) {
      Serial.println("[BT] Phone Connected");
      bluetooth.println("STATUS:DISARMED");
      isArmed = false;
      isAlarmActive = false;
      noTone(BUZZER_PIN);
    } else {
      Serial.println("[BT] Phone Disconnected -> auto-arm");
      bluetooth.println("STATUS:ARMED");
      isArmed = true;
    }
    previousConnectionState = currentConnectionState;
  }

  if (bluetooth.available()) {
    String command = bluetooth.readStringUntil('\n');
    command.trim();

    if (command == "CMD:ARM") {
      isArmed = true;
      bluetooth.println("STATUS:ARMED");
      Serial.println("Manually armed");
    }
    else if (command == "CMD:DISARM") {
      isArmed = false;
      isAlarmActive = false;
      noTone(BUZZER_PIN);
      bluetooth.println("STATUS:DISARMED");
      Serial.println("Manually disarmed");
    }
    else if (command.startsWith("CMD:HOLD:")) {
      int newHold = command.substring(9).toInt();
      if (newHold >= 50 && newHold <= 1000) {
        MOVE_THRESHOLD = newHold / 100.0;
      }
    }
  }

  if (millis() - lastTelemetryTime >= 100) {
    lastTelemetryTime = millis();

    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);

    float x = a.acceleration.x / 9.80665;
    float y = a.acceleration.y / 9.80665;
    float z = a.acceleration.z / 9.80665;

    bluetooth.print("ACCEL:");
    bluetooth.print(x, 4);
    bluetooth.print(",");
    bluetooth.print(y, 4);
    bluetooth.print(",");
    bluetooth.println(z, 4);
  }

  if (isAlarmActive) {
    unsigned long elapsed = millis() - alarmStartTime;

    if (elapsed < ALARM_DURATION) {
      unsigned long cycle = elapsed % 600; // beep pattern
      if (cycle < 180) {
        tone(BUZZER_PIN, alarmFreq);
      } else {
        noTone(BUZZER_PIN);
      }
    } else {
      noTone(BUZZER_PIN);
      isAlarmActive = false;
      Serial.println("Alarm ended");
    }

    return;
  }

  if (isArmed) {
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);

    float totalAccel = sqrt(
      a.acceleration.x * a.acceleration.x +
      a.acceleration.y * a.acceleration.y +
      a.acceleration.z * a.acceleration.z
    );

    float gravity = 9.8;
    float change = abs(totalAccel - gravity);

    if (change > MOVE_THRESHOLD) {
      isAlarmActive = true;
      alarmStartTime = millis();
      bluetooth.println("THEFT_DETECTED");
      Serial.println(">>> THEFT DETECTED <<<");
    }
  }

  delay(20);
}