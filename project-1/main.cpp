#include <iostream>

using namespace std;

enum Status
{
    TODO,
    PENDING,
    COMPLETED
};

int main()
{
    cout << "Hello World" << endl;

    // Variables
    int myNum = 8;
    cout << myNum << endl;
    double pi = 3.14;
    cout << pi << endl;
    char firstLetter = 'A';
    cout << firstLetter << endl;
    string name = "sachin";
    cout << name << endl;

    // enums
    enum Status current = PENDING;
    cout << current << endl;

    // Reference variables
    string food = "pizza";
    string &meal = food;
    cout << food << endl;
    cout << meal << endl;

    cout << "Memary adress of food \t:\t" << &food << endl;
    cout << "Memory address of meal \t:\t" << &meal << endl;

    return 0;
}