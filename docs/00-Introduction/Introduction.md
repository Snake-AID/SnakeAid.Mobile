(*) 3.1. Capstone Project name:
English: AI-Powered Platform for Snakebite First Aid and Rescue Support
Vietnamese: Nền tảng hỗ trợ sơ cứu & cứu hộ rắn cắn ứng dụng AI
Abbreviation: SnakeAid
a.      Context:
Snakebite incidents are often poorly handled due to lack of timely first aid, misidentification of snake species, limited access to nearby antivenom facilities, and slow rescue coordination. Patients frequently panic and perform harmful treatments, while rescuers face risk without accurate species information. Experts are not always available for quick verification, and incident data is fragmented. Administrators lack real-time visibility of high-risk areas and rescue efficiency. Therefore, an AI-powered platform integrating first-aid support, snake identification, rescue tracking, expert consultation, and incident monitoring is urgently needed.
b.      Proposed Solutions
AI-Powered Platform for Snakebite First Aid and Rescue Support is a platform that provides a comprehensive solution involving patients, rescuers, snake experts, and administrators. Patients receive step-by-step first-aid guidance, AI-based snake identification and severity assessment, SOS emergency calls with GPS sharing, real-time map tracking of rescue teams, symptom monitoring, and direct payments for consultations and rescue services. Snake rescuers receive alerts, manage rescue tasks, identify snake species via AI, navigate to incident locations using map-based guidance, update status, and track revenue. Snake experts verify images, provide remote consultation, update treatment guidelines, and manage earnings. Admins oversee user roles, snake database, treatment facilities, content, system analytics, map-based activity monitoring, alerts, and platform-wide financial reports.
c.      Functional requirement
○  	Module for Patient
●  	Emergency first-aid guidance: step-by-step instructions, compression bandage guide, warnings about prohibited actions.
●  	Emergency call: SOS button sends GPS location and directly calls the emergency hotline.
●  	Locate nearest treatment facility with antivenom: map display based on admin-updated data.
●  	Track bite and symptoms: input descriptions, take photos to monitor progression.
●  	Snake species identification from image (AI): recognize the snake and provide appropriate first-aid guidance.
●  	Assess severity from bite image and symptoms (AI): issue urgent alerts and suggest calling emergency services if critical.
●  	Report snakebite incident / snake sighting: send location and images to the system or snake rescuer.
●  	Snake prevention & education: articles, videos, FAQs.
●  	Real-time map tracking:
✔ 	Track snake rescue team’s real-time location after requesting rescue.
✔ 	Receive notifications when the rescue team is approaching or has completed the mission.
✔ 	Display estimated arrival route and time.
●  	Service fee management:
✔ 	Pay fees for expert snake consultation.
✔ 	Pay snake rescue fees directly to rescue teams via the platform.
✔ 	Track payment status and electronic invoices.
 
○  	Module for Snake Rescuer
●  	Receive snake sighting alerts / rescue requests: access location and images.
●  	Verify & respond quickly: confirm snake type (venomous/non-venomous), update results.
●  	Rescue task management: accept, handle, update progress (en route, completed).
●  	Safety guidance for capturing and relocating snakes: standard operating procedures.
●  	Communicate & collaborate with snake experts: exchange details for accurate identification and response.
●  	Record & report rescue activities: document cases, locations, and timelines.
●  	Map tracking:
✔ 	Update team’s real-time movement.
✔ 	Support navigation to patient’s location.
✔ 	Send status notifications (on the way, completed).
●  	Identify snake species from patient-submitted images (AI): provide risk warnings before arrival.
●  	Rescue fee management:
✔ 	Accept paid rescue requests (from patients).
✔ 	Track revenue, payment status, and transaction history.
✔ 	Receive payment via platform after rescue completion.
✔ 	Rate and receive feedback to improve ranking priority.
 
○  	Module for Snake Expert
●  	Verify identification data: confirm snake species from images/descriptions.
●  	Support AI-based species identification to shorten verification time.
●  	Update handling & first-aid guidelines by snake type.
●  	Remote consultation: online support for patients or rescue teams.
●  	Consultation revenue management:
✔ 	Set online consultation fees.
✔ 	Receive payments via platform and issue electronic invoices.
✔ 	View monthly/quarterly revenue reports.
 
○  	Module for Admin
●  	User & role management: create accounts for patients, experts, and rescuers.
●  	Snake species database management: images, traits, distribution, behavior.
●  	Treatment facility management: facility name, location, available antivenom types.
●  	Content management: update first-aid guidance, snake data, risk areas.
●  	Data statistics & reporting: compile snakebite cases, rescues, consultations, and system activity.
●  	Community alerts & announcements: send risk area alerts, prevention guidance.
●  	Platform fee & revenue management:
✔ 	Manage service fee (rescue, consultation).
✔ 	Track total revenue, distribute earnings to rescuers/experts.
✔ 	Manage payments among patients – rescuers/experts – platform.
✔ 	Generate periodic financial reports.
d.      Non-functional requirement:
○      The system is capable of keeping track of the user at the time when the user performs important processing functions in the system.
○      Unicode font.
 (*) 3.2. Main proposal content (including result and product)  
a.      Theory and practice (document):
○      Students should apply the software development process in the modelling system.
○      The documents include User Requirement, Software Requirement Specification, Architecture Design, Detail Design, Testing Document, Installation Guide, User Guide, Sources Code.
○      Server-side technologies:
●     Server: .NET, Windows Azure/AWS, …
●     Database Design: SQL Server, MySQL, …
○      Client-side technologies:
●     Web Client: HTML5, CSS3, Typescript, ReactJS, ....
●     Mobile App:  Flutter, Xamarin, …
b.      Products:
○      Mobile/Web App for Patient.
○      Mobile/Web App for Snake Rescuer.
○      Mobile/Web App for Snake Expert.
○      Web App for Admin.
c.      Proposed Tasks:
○      Task package 1: Develop the application.
○      Task package 2: Build and Test the system.
○      Task package 3: Prepare all the required documents: System analysis and Design, Test plan, Installation manual, User manual.