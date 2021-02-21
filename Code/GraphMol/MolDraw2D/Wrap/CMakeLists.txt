remove_definitions(-DRDKIT_MOLDRAW2D_BUILD)
<<<<<<< HEAD

if(RDK_BUILD_QT_SUPPORT)
  find_package(Qt5 COMPONENTS Widgets OpenGL REQUIRED)
  set( QtDrawingLibs Qt5::Widgets Qt5::OpenGL )
endif(RDK_BUILD_QT_SUPPORT)

rdkit_python_extension(rdMolDraw2D
                       rdMolDraw2D.cpp
                       DEST Chem/Draw
                       LINK_LIBRARIES MolDraw2D ${QtDrawingLibs} )
=======
rdkit_python_extension(rdMolDraw2D
                       rdMolDraw2D.cpp
                       DEST Chem/Draw
                       LINK_LIBRARIES MolDraw2D )
>>>>>>> d24111c9f5ea0c129a2416f0888f8fadb42d53c0

add_pytest(pyMolDraw2D ${CMAKE_CURRENT_SOURCE_DIR}/testMolDraw2D.py)
if(RDK_BUILD_QT_SUPPORT)
  add_pytest(pyMolDraw2DQt ${CMAKE_CURRENT_SOURCE_DIR}/testMolDraw2DQt.py)
endif(RDK_BUILD_QT_SUPPORT)
