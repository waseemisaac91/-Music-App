# musicapp_flutter
#By Waseem Isaac

A new Flutter project.

## Getting Started

build a mobile web site and an Android application for a music site. They are both a portal for a site called MusicSite. It contains a list of songs that are available in the web site.
The database consists of the following tables:
•Customer (Id, Username, password, FName, LName, Address, Email)
•artist (Id, Fname, Lname, gender, country)
•Song (Id, Title, Type, Price , ArtistId)
•Invoice (Id, Customer_Id ,Date, Total, CreditCard )
•order (Id, Song_id, Invoice_id)
You are required to build the following mobile application by flutter IDE
1.A page (route) to login.
2.A page to sign-up a new customer.
3.A page to add an artist (the admin should be logged in)
4.A page to add a song (the admin should be logged in)
5.A page to display all songs. When the customer selects a song, the details of the song and its artist are displayed.
6.A page to display all artists. When the customer selects an artist, the details of the artist are displayed.
7.A page to search for a song by part of its title. The customer can select a song to see its details
8.A page to search for an artist by part of its last name or first name. The customer can select an artist to see the songs which he sang.
9.A page to buy song(s) and enter a credit card number.
