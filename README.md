This is a traditional approach for license plate detection in images, employing fundamental computer vision techniques. The method includes the conversion of RGB images to grayscale,
edge enhancement through morphological operations, and processing of horizontal and vertical histograms for effective edge detection. 
Utilizing a moving average window and dynamic thresholding enhances the smoothness and accuracy of the histograms for each edge detection technique.
The algorithm identifies potential candidates for the number plate region based on peak values in the histograms, eliminating regions outside the most probable candidate.
The simplicity of this approach makes it suitable for scenarios with limited computational resources
the above process is done in MATLAB platform
