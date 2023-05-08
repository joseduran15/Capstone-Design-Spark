# Capstone-Design-Spark

To run Spark:

1. Download the latest version of Xcode from the Apple Appstore (must be using a Mac).
2. Clone the Spark repository and open Spark.xcodeproj with Xcode.
3. Put your Apple phone in Developer Mode, by going to Settings->Privacy and Security and toggling the Developer Mode switch (you will have to restart your phone). This will only work on an Apple phone, Spark cannot run on Androids. 
4. Plug your iPhone into your Mac and select your phone from the list of devices at the top of the screen in Xcode. Attempt to run the app. Likely, it will tell you you need to trust this developer, so go to Settings->General->VPN and Device Management and click on the developer, then click Trust.
  - Note: You cannot run Spark on a simulator due to taking photos not working on simulators, you must use a physical iPhone.
5. The app will take a little bit to build the first time, and if it works, a message will pop up saying "Build Succeeded" on your computer, and Spark will open on your phone after a few seconds. Now you can use it!
  - Note: The first time you attempt to use the photo-taking feature in profile creation, the app will crash and you will need to build it again. This is an issue with     the Xcode debugger.
