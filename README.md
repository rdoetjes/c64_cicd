# c64_cicd demo pipeline with deploy to C64

With the Ultimate-II and Ultimate-64 we can now star applications by calling the Rest API on those devices.
It will in turn load the program into the c64 and start it. This is a hot deploy and thus my CI/CD brain immediately wante to do this and I wrote this eample CI/CD pipeline using GitHub actions.

## Reasons to use it
First of all this was a good practical case to show the power of GitHub actions in a video.

But let's be honest when we all develop for our C64 we all do that on our massively powerful computers that provide us with cool debuggers- ,editting solutions and syntax highlighting and we then run and test it in our emulators. 
And only when that works we take out the thumb drive of our Ultimate-II or Ultimate64 and we upload the code there and then select and run it through the Ultimate-xx.
Well that last step is tedious, even when I already uploaded my compiled PRG to the Ultimate-II+ using FTP, I still needed to do this.
And we tend to only want to run it on real hardware after we publish our code into our repository.
This allows you to do that! Without an afterhought. You just have you C64 on whilst you develop and when you commit after your preliminary test on the emulator works, it will actually build it and push it to your C64 for a final check.

## Makefile can also call the API
Yeah I know, but what is the fun at that? ;) We are already engaging in useless stuff which is retro computing so make it more fun and even more uselss :D

## self-hosted runner (build agent)
It is very important from a security perspective to use a self-hosted runner (build agent) that agent should be on the same network as your Ultimate-II or Ultimate-64. You *DO NOT WANT TO USE THE PUBLIC RUNNERS AND OPEN UP PORT 80 TO YOUR Ultimate!*
In the video I explain how to setup a runner on Linux (similar on Mac and Windows as githun guides you through it)

## The demo pipeline
The demo pipeline does a few things:

Step one is to checkout your repositore, *this changes the current directory to the directory with your code!*
```yaml
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v3
```
Then we install KickAssembler (it only has one file) *you do need to have java already installed on your runner*
We will only download KickAss if it is not already on the runner
```yaml
      - name: Install KickAss if needed
        run: |
          set -e
          cd ${{ runner.workspace }}
          if ! [ -f KickAss.jar ] ;then
            echo "Installing KickAss"
            curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:58.0) Gecko/20100101 Firefox/58.0" -X GET http://theweb.dk/KickAssembler/KickAssembler.zip --output KickAssembler.zip
            unzip -o KickAssembler.zip  
          else
            echo "Already installed proceeding."
          fi
```

Then we build our main.asm file with Kick Assembler
```yaml
      - name: Build asm
        run: | 
          set -e
          java -jar ${{ runner.workspace}}/KickAss.jar $GITHUB_WORKSPACE/main.asm -odir ${{runner.workspace}}/build -o ${{ runner.workspace}}/build/main.prg
```
And finally we push the build PRG to the C64
 - name: Deploy to C64
        run: |
          curl -H "Content-Type multipart/form-data" -F  "file=@${{runner.workspace}}/build/main.prg" "http://192.168.178.156/v1/runners:run_prg" -v
