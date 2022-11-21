import json
import random
import math


#create array of first names, three "interests" from list we give, pronouns
#for each dictionary generate random first name, random lat/long in dc area, userID, age, 

# Data to be written
users = []

names = ["Michael", "Sarah", "Emily", "John", "Jay", "Cornelius", "Juan", "Rebecca", "Melissa", "Savannah", "Edison", "Liam", "Nelson", "Bob", "Lulu", "Jones", "Devin",
        "Nassar", "William", "Hubert", "Lisa", "Bart", "Robert", "River", "Lily", "Miranda", "Meg", "George", "Robert", "Miles", "Alex", "Noah", "Jack", "Jill", "Jose",
        "Gordon", "Ulysses", "Odysseus", "Achilles", "Athena", "Jeff", "Lee", "Jeffrey", "Vin Diesel", "Guy Fieri", "Paul", "Bartholomew", "Sophia", "Sophie", "Sloane",
        "Betty", "Berry", "Snoop Dog", "Perry", "Ferb", "Lucy", "Cole", "Carolyn", "Ailee", "Ishani", "Mya", "Rosalia", "Blue", "Feather", "Savannah,", "Ana", "Gabrielle",
        "Genji", "Eld", "Sudo", "Dimitri", "Ferdinand", "Claude", "Khalid", "Manasi", "Jordan", "Spencer", "Seth", "Liv", "Lexi", "Chrysanthemum", "Lorelei", "Galadriel",
        "Aragorn", "Legolas", "Gimli", "Frodo", "Pippin", "Sauron", "Edelgard", "Mario", "Luigi", "Bowser", "Princess Peach", "Mary Jane", "Jim Bob", "Bernie", "Izzy",
        "Lili Beth", "Veronica", "Lynnette", "Krysti", "Sephiroth", "Gideon", "Zeus", "Jupiter", "Percy", "Annabeth", "Carter", "Sadie", "Clara", "Solomon", "Lilibet",
        "Narcissus", "Anthony", "Paul", "Stochastic", "Donnie", "Walter", "Terry", "Gerald", "Keith", "Kristian", "Mimi", "May", "April", "June", "December", "July",
        "Joy", "Augustine", "Mason", "Phillip", "Russell", "Philip", "Patricia", "Nancy", "Kathy", "Margaret", "Carol", "Michelle", "Donna","Kim", "Maithy", "Ara",
        "Donghyun", "Jeong", "Jun", "Carina", "Anushka", "Kashvi", "Kimaya", "Tara", "Tanvi", "Zara", "Sneha", "Andressa", "Edict", "Fernanda", "Kimi", "Mikki", 
        "Anthy", "Izabel", "Fernando", "Mareline", "Madeleine", "Marcos", "Rosa", "Viola", "North", "Snowy", "Paulina", "Tacito", "Claudia", "Cipriano", "Ignacio",
        "Carmen", "Maple", "Elmer", "Clifford", "Clayton", "Leonardo", "Luan", "Sandile", "Lydia", "Amahle", "Annika", "Charlize", "Imka", "Nomusa", "Retha", "Unathi"]

genderList = ["Female", "Male", "Nonbinary"]

#decide sexual orientation randomly
def decideOrientation(gender):
    num = random.uniform(0, 1)
    if gender == "Female":
        if num >= 0.3:
            return "Male"
        if num > 0.1 and num < 0.3:
            return "All"
        if num <= .1:
            return "Female"
    if gender == "Male":
        if num >= 0.3:
            return "Female"
        if num > 0.1 and num < 0.3:
            return "All"
        if num <= .1:
            return "Male"
    if gender == "Nonbinary":
        if num >= 0.6:
            return "Male"
        if num > 0.3 and num < 0.6:
            return "All"
        if num <= .3:
            return "Female"

def ageRangeFunc(age):
    ageLower = math.floor(random.uniform(18,age))
    ageUpper = math.floor(random.uniform(ageLower,45))
    return (ageLower, ageUpper)

# between 38.81 and 38.98 dc latitude
# between -76.91 and -77.05 dc longitude

for x in range(0, 10):
    gender = random.choice(genderList)
    orientation = decideOrientation(gender)
    age = math.floor(random.uniform(18,45))
    ageRange = ageRangeFunc(age)

    dictionary = {
        "userID": x,
        "name": random.choice(names)
    }

    locDict = {
        "lat": random.uniform(38.81, 38.98),
        "long": random.uniform(-76.91, -77.05)
    }

    ageDict = {
        "age": age,
        "ageLowerRange": ageRange[0],
        "ageUpperRange": ageRange[1]
    }

    gendDict = {
        "gender": gender,
        "orientation": orientation
    }

    dictionary["locData"] = locDict
    dictionary["ageData"] = ageDict
    dictionary["gendData"] = gendDict

    users.append(dictionary)

 
# Serializing json
json_object = json.dumps(users, indent=4)
 
# Writing to sample.json
with open("sample.json", "w") as outfile:
    outfile.write(json_object)