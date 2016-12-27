# Big Data Review Analysis
Can tell you the difference between positive and negative movie reviews using Machine Learning.

**Keep in mind that it took me several days/weeks and beers to create this project
So please be kind and give me credits for this code. I won't bite**

## Ready, Set,.. LEARN!
Now that you know your legal rights after reading the 2 lines above we can finally start this journey to machine learning and letting your computer tell you if a movie review is positive or negative

I haven't come up with a name yet, so if you can make up one, please let me know.

The program is very nice and willing to learn, but you need to train him/her. It's just like Pokemon.
Except that I work Naive Base and the you can train me from data in datasets instead of TM's of your TM CASE

In order to use me, simply run main.R. Now you can call a variaty of commands, let's start at the beginning:
##### Build a skillset
  * If we already learned something, call ```learn.load()```
  * If we don't know anything, call: ```learn.teach()```
  * To make the program even smarter (Append skillzz), call: ```learn.load()``` first and then ```learn.teach()```
  
##### Test our skillset
  1. Call the ```sentiment.test()``` function.
  2. Select your test set
  3. Tell what to make
  4. Await results
  5. **If you run this on a Mac** you can use Threading by running the threaded.R file and calling: ```sentiment.test.threaded()``` (This will currently not show a progressbar but is much faster, duhhh)
  
##### Test your own review
  1. Call the ```sentiment.calc(<your review string>)``` function
  2. After sometime. You will know if the review was positive or negative
  
##### Save what you learned
  * Call the ```learn.save()``` function
  
## That all sound nice, but what are all the functions so I can mess with them myself?
You just need to ask nicely:
  * ```console.ask(string, type=string)``` => Internal use only, ask for a string or integer
  * ```console.confirm(string)``` => Internal use only, ask a true/false question
  * ```learn.load()``` => Let's dig in my memory to see what I learned before
  * ```learn.save()``` => Let me remember everything I just learned
  * ```learn.teach()``` => Teach me new stuff
  * ```sentiment.calc(string, progress=boolean)``` => Check if a string is positive or negative, with or without a progressbar
  * ```sentiment.split(string)``` => Internal use only, splits a string
  * ```sentiment.test()``` => Dare to test me
  * ```sentiment.train(string, 0|1)``` => Learn me that string is positive (1) or negative (0)
  * ```set.import(string)``` => Import csv from given path
  
### Threaded functions
**Currently these only work on the best computer system there is: MacOS**
I can be so much faster when I use all the 4 cores of my brain. Call these and set me free
  * ```sentiment.test.threaded()``` => Dare to test me. Progressbar currently NOT showing
