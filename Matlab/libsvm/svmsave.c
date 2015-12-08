 
#include "svm.h"
#include "mex.h"
#include "svm_model_matlab.h"
#define CMD_LEN 2048
#define FILENAME_LEN 256

void exit_with_help(){ }

static void fake_answer(mxArray *plhs[]) { plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL); }

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
struct svm_model *model;
if (nrhs > 3 || nrhs < 1) {
exit_with_help();
fake_answer(plhs);
return;
}
if (mxIsStruct(prhs[0])){
const char *error_msg;
//model = (struct svm_model *) malloc(sizeof(struct svm_model));
model = matlab_matrix_to_model(prhs[0], &error_msg);
if (*error_msg) {
mexPrintf("Error: can't read model: %s\n", *error_msg);
//svm_destroy_model(model);
fake_answer(plhs);
//return;
}
if (mxIsChar(prhs[1])) {
long unsigned int buflen,status;
char filename[FILENAME_LEN];
buflen = (mxGetM(prhs[1]) * mxGetN(prhs[1])) + 1;
//filename = mxCalloc(buflen, sizeof(char));
status = mxGetString(prhs[1], filename, buflen);
if (status != 0) mexWarnMsgTxt("Not enough space. String is truncated.");
svm_save_model(filename,model);
}
else {
mexPrintf("filename should be given as char(s)\n");
}
//svm_destroy_model(model);
}
else {
mexPrintf("model file should be a struct array\n");
fake_answer(plhs);
}
return;
}