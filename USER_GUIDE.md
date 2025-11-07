## User guide for CareerCompass

This document will guide you on all the features of the CareerCompass application. CareerCompass aims to provide Singaporean students with an easy overview of data from the Graduate Employment Survey, helping students make more informed decisions when choosing a particular course. We provide visualisations that allow students to see the change over time for various statistics for every course, and allow students to compare between courses.

### 1. Login, Signup and User accounts

#### 1.1 Account creation
You are able to create an account. Some features are locked behind account creation (eg. Trends, Compare and Bookmarks). When creating an account, you are required to provide the following:

- Username
- Valid email address
- Password that meets the complexity requirements:
    - At least 8 alphanumeric characters
    - At least 1 uppercase character
    - At least 1 number
    - At least 1 special character

Passwords are hashed and salted with `bcrypt`, using the `has_secure_method` when creating an account. Only the password digest is saved.

#### 1.2 Login
To login, enter your registered email address and password. 

#### 1.3 Reset password
If you have forgotten your password, you can click the "Forgot password?" link on the login page. Enter your registered email address and a password reset link will be mailed to you. Note that the link expires within 15 minutes, and thereafter you have to request for a new link.

Enter a new password that meets the same complexity requirement as in section 1.1. You will be required to re-enter the same password as a confirmation.

#### 1.4 Update profile
You will be prompted to update your profile if you have not done so. Click on the user icon on the navbar, and a dropdown menu will appear. Click the "Profile" button to see your personal information. By default, these are pre-filled with "Not Set" fields, and you are encouraged to fill up your current institution, course, year of study and personal interests. These will help to deliver more personalised suggestions.

### 2. Search
CourseCompass contains a repository of almost all university-level degree courses for Singapore universities, taken from https://data.gov.sg/. To search, simply click the Search button at the top of the screen or use the search bar on the homepage. 

You can enter keywords and select certain filters (by university, employment rate, salary, course duration).

#### 2.1 Quick access links
The homepage also contains a few quick access links below the search bar for easy access to commonly-used features (Bookmarks, Profile, View courses). The view courses button will display all available courses.

### 3. Trends
You can select up to 5 bookmarks to compare the trend over time for a particular metric. This will display a time series chart, allowing you to see the change over time of each metric.

### 4. Compare
You can select up to 5 bookmarks to build a comparison table. Choose one or more metrics to be displayed side-by-side, and select the academic year to retrieve data from. An indicator is provided to show the relative year-on-year change.