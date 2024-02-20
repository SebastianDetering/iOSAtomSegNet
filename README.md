
<h4>Original Paper</h4>
https://www.nature.com/articles/s41598-021-84499-w

<h4>Original Atom Seg Net</h4>
https://github.com/xinhuolin/AtomSegNet
Developed for the DeepEM Lab at UC Irvine led by Professor Huolin Xin

<h4>App Store</h4>
https://apps.apple.com/us/app/atom-seg-net/id1626926737


<h3>Atom Segmentation Network iOS Description</h3>

A Machine Learning App for all Platforms
Starting Summer 2021, with the support of a grant from UCI's Summer Undergraduate Research Proposal, I began developing MatLab and iOS versions for the processing of Atom Resolution images.  The machine learning model was trained in UCI Professor Huolin Xin's group; you can read the original publication here.  The machine learning originates in python, but I have finished developing the iOS version March 2022, published July (I dealt with some publishing problems with Apple).  The app will allow exploration of machine learning in a user-friendly way.  A huge benefit is to show the non-coding public a neural network in action!

App Archicture
The app is built using SwiftUI, apple's newest User Interface API.

SwiftUI uses a declarative programming style Model View ViewModel or MVVM.  The MVVM style of programming has the benefit of being easier to read and debug.  SwiftUI also makes it easy to develop for more apple platforms once one version is complete, easier than it was using UIKit.

The machine learning model is powered by CoreML, Apple's (also cutting edge) machine learning API.  CoreML is so new, it is still impossible as of March 2022 to design your own UNet architecture in Create ML.app.  Instead you must use a python tool (CoreMLTools) to convert the models from Pytorch to CoreML. 

This was a breakthrough in my project, however some boilerplate code was needed. For this I designed an image processing pipeline which converts PNGs to CGImage, CGImage data to MLMultiArray for model input, and MLMultiArray back to CGImage for model output. 
This is all blazing fast thanks to low level frameworks.

With the pipeline working, I implemented persistent data stores (Core Data) to hold images permanently in the app.
For a finished version, import and export capability allow the user to share images.
This app is a great example of implementing machine learning for everyone. 

<h3>Dependencies</h3>

<h6>Swift Package manager packages:</h6>
Introspect
PermissionsSwiftUI

<h6>Carthage:</h6>

Linear Algebra swift (LASwift)
https://github.com/AlexanderTar/LASwift
this package helped a lot with image 2d manipulation logic

Carthage has been the most difficult to get working with a fresh XCode Project.
https://github.com/Carthage/Carthage.git
The docs suggest running `carthage bootstrap` when dependencies are already built like in this project.
when updating using Carthage, use `carthage update --use-xcframeworks` 


<h4>Todos</h4>

Add the LASwift dependency with Swift Package manager instead of Carthage.

Why?
Setting this project up from this repository may not run because it will say ` LASwift module was compiled in Swift 5.6 ` ...I dont know how to solve this problem
But restarting my project seemed to work once. Seb-Feb 19 6pm

The electron microscope file parsers were included as a utility, but they are incomplete.  Error handling and functionality are much needed features.

Warning: running on a iOS simulation will NOT work.  This is because CoreML needs real hardware to work.  Run this with a iphone/ipad connected and configured for development

<h5>MIT License
</h5>

Copyright 2022 DeepEM Lab at UCI

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
